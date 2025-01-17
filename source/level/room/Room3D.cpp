
#include <graphics/3d/perspective_camera.h>
#include <utils/camera/flying_camera_controller.h>
#include <utils/json_model_loader.h>
#include <graphics/3d/tangent_calculator.h>
#include <game/dibidab.h>
#include "Room3D.h"
#include "../../generated/Camera.hpp"
#include "../../game/Game.h"
#include "../../ecs/systems/ArmatureAnimationSystem.h"
#include "../../ecs/systems/TransformSystem.h"

Room3D::Room3D()
{
    templateFolder = "scripts/entities/level_room/";

    loadedMeshAttributes
        .add_(VertAttributes::POSITION)
        .add_(VertAttributes::NORMAL)
        .add_(VertAttributes::TANGENT)
        .add_(VertAttributes::TEX_COORDS);

    loadedRiggedMeshAttributes = loadedMeshAttributes;
    loadedRiggedMeshAttributes
        .add_(VertAttributes::BONE_WEIGHT_0)
        .add_(VertAttributes::BONE_WEIGHT_1)
        .add_(VertAttributes::BONE_WEIGHT_2)
        .add_(VertAttributes::BONE_WEIGHT_3);

    addSystem(new ArmatureAnimationSystem("Armature animations"));
    addSystem(new TransformSystem("Transforms"));
}

vec3 Room3D::getPosition(entt::entity e) const
{
    return entities.has<Transform>(e) ? entities.get<Transform>(e).position : vec3(0);
}

void Room3D::setPosition(entt::entity e, const vec3 &pos)
{
    entities.get_or_assign<Transform>(e).position = pos;
}

void Room3D::initializeLuaEnvironment()
{
    Room::initializeLuaEnvironment();

    luaEnvironment["currentRoom"] = luaEnvironment;
    luaEnvironment["setMainCamera"] = [&] (entt::entity e) {
        cameraEntity = e;
    };
    luaEnvironment["getMainCamera"] = [&] {
        return cameraEntity;
    };
    luaEnvironment["loadModels"] = [&] (const char *path, bool force) {
        loadModels(path, force, &uploadingTo, loadedMeshAttributes);
    };
    luaEnvironment["loadRiggedModels"] = [&] (const char *path, bool force) {
        loadModels(path, force, &uploadingRiggedTo, loadedRiggedMeshAttributes);
    };
    luaEnvironment["project"] = [&] (const vec3 &pos) {
        if (!camera)
            return sol::optional<ivec2>();
        bool inViewport = false;
        vec3 pixelPos = camera->projectPixels(pos, inViewport);
        if (!inViewport)
            return sol::optional<ivec2>();
        return sol::optional(ivec2(pixelPos));
    };
    luaEnvironment["setPaused"] = [&] (bool p) {
        paused = p;
    };
    luaEnvironment["setSkySpeed"] = [&] (float s) {
        skyTimeMultiplier = s;
    };
}

void Room3D::update(double deltaTime)
{
    if (!paused)
        Room::update(deltaTime);

    skyTime += deltaTime * skyTimeMultiplier;
    updateOrCreateCamera(deltaTime);
}

Room3D::~Room3D()
{
    delete camera;
}

mat4 Room3D::transformFromComponent(const Transform &t)
{
    mat4 mat(1.0f);

    mat = glm::translate(mat, t.position);

    // rotation.. http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/
    mat *= glm::toMat4(t.rotation);

    mat = glm::scale(mat, t.scale);

    return mat;
}

Camera *Room3D::cameraFromEntity(entt::entity e) const
{
    if (!entities.valid(e))
        return NULL;

    auto *pers = entities.try_get<CameraPerspective>(e);
    auto *trans = entities.try_get<Transform>(e);

    if (pers && trans)
    {
        auto cam = new PerspectiveCamera(pers->nearClipPlane, pers->farClipPlane, gu::width, gu::height, pers->fieldOfView);
        cam->position = trans->position;

        mat4 transform = transformFromComponent(*trans);
        cam->up = transform * vec4(cam->up, 0);
        cam->direction = transform * vec4(cam->direction, 0);
        cam->right = transform * vec4(cam->right, 0);
        cam->update();
        return cam;
    }

    return NULL;
}

void Room3D::updateOrCreateCamera(double deltaTime)
{
    static bool flyingCam = false;
    static entt::entity camEntityBeforeFlying;
    if (flyingCam && (KeyInput::justPressed(Game::settings.keyInput.stopFlyingCamera) || !dibidab::settings.showDeveloperOptions))
    {
        MouseInput::setLockedMode(false);
        flyingCam = false;
    }

    if (KeyInput::justPressed(Game::settings.keyInput.flyCamera) && !!camera && dibidab::settings.showDeveloperOptions)
    {
        camEntityBeforeFlying = cameraEntity;
        flyingCam = true;
    }

    if (flyingCam)
    {
        static float speedMultiplier = 1;
        FlyingCameraController camController(camera);
        camController.speedMultiplier = speedMultiplier;
        camController.update(deltaTime);
        speedMultiplier = camController.speedMultiplier;

        {
            ImGui::SetNextWindowBgAlpha(0);
            ImGui::SetNextWindowPos(ImVec2(50, 50));
            ImGui::SetNextWindowSize(ImVec2(400, 100));
            ImGui::Begin("Flying cam info", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize);
            ImGui::Text("Press [%s] to cancel flying\n\n[Left Mouse Button] to save camera's new position\n\nScroll to change speed: %.1f", KeyInput::getKeyName(Game::settings.keyInput.stopFlyingCamera), speedMultiplier);
            ImGui::End();
        }

        static const int PRIO = 10;
        MouseInput::capture(GLFW_MOUSE_BUTTON_LEFT, PRIO);
        if (MouseInput::justPressed(GLFW_MOUSE_BUTTON_LEFT, PRIO))
        {
            flyingCam = false;
            MouseInput::setLockedMode(false);
            if (entities.valid(camEntityBeforeFlying))
            {
                if (auto *t = entities.try_get<Transform>(cameraEntity))
                {
                    t->position = camera->position;
                    t->rotation = quatLookAt(camera->direction, camera->up);
                }
            }
        }
    }
    else
    {
        delete camera;
        camera = cameraFromEntity(cameraEntity);

        if (!camera)
        {
            camera = new PerspectiveCamera(.1, 1000, 1, 1, 75);
            camera->position = vec3(10);
            camera->lookAt(mu::ZERO_3);
            camera->viewportWidth = gu::width;
            camera->viewportHeight = gu::height;
            camera->update();
        }
    }
}

bool Room3D::loadModels(const char *path, bool force, VertBuffer **vbPtr, const VertAttributes &attrs)
{
    if (!force && modelFileLoadTime.find(path) != modelFileLoadTime.end())
        return false;

    std::unordered_map<Mesh *, bool> calculatedTangents;

    for (auto &model : JsonModelLoader::fromUbjsonFile(path, &attrs))
    {
        if (!*vbPtr || (*vbPtr)->isUploaded())
            *vbPtr = VertBuffer::with(attrs);

        models[model->name] = model;
        for (auto &part : model->parts)
        {
            if (!part.mesh)
                continue;
            if (!calculatedTangents[part.mesh.get()])
            {
                for (int i = 0; i < part.mesh->parts.size(); i++)
                    TangentCalculator::addTangentsToMesh(part.mesh, i);
                calculatedTangents[part.mesh.get()] = true;
            }
            if (!part.mesh->vertBuffer)
                (*vbPtr)->add(part.mesh);
        }
    }
    modelFileLoadTime[path] = glfwGetTime();
    return true;
}
