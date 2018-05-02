defmodule Ex2.Task.Projection do
  alias Ex2.Task.Events

  def apply(%Events.Created{} = created, entity) do
    # do something with entity and created
    Ex2.Task.created(entity, created.time)
    # return new entity
    entity
  end

  def apply(_, entity) do
    entity
  end
end
