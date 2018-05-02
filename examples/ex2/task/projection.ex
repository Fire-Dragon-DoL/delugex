defmodule Ex2.Task.Projection do
  def apply(%Ex1.Events.Created{} = created, entity) do
    # do something with entity and created
    Ex2.Task.created(entity, created.time)
    # return new entity
    entity
  end

  def apply(_, entity) do
    entity
  end
end
