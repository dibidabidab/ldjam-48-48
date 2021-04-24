
#ifndef TRANSFORM_SYSTEM_H
#define TRANSFORM_SYSTEM_H

#include <ecs/systems/EntitySystem.h>

class TransformSystem : public EntitySystem
{
  public:
    using EntitySystem::EntitySystem;

  protected:
    void update(double deltaTime, EntityEngine *engine) override;

};


#endif
