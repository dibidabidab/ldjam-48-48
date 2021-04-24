
#include "TransformSystem.h"
#include <generated/Children.hpp>
#include <ecs/EntityEngine.h>
#include "../../generated/Transform.hpp"
#include "../../level/room/Room3D.h"

void TransformSystem::update(double deltaTime, EntityEngine *engine)
{
    engine->entities.view<Child, Transform, ParentOffset>().each([&](Child &child, Transform &transform, ParentOffset &offset) {

        mat4 parentMat(1.);

        if (Transform *parentTransform = engine->entities.try_get<Transform>(child.parent))
            parentMat = Room3D::transformFromComponent(*parentTransform);

        transform.position = parentMat * vec4(offset.position, 1.);
        transform.rotation = toQuat(parentMat) * offset.rotation;
        transform.scale = parentMat * vec4(offset.scale, 0.);
    });
}
