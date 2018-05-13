defmodule EspEx.EventBus.PostgresTest do
  use ExUnit.Case, async: true
  alias EspEx.EventBus.Postgres

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EspEx.Repo)

    %{
      uuid: UUID.uuid4(),
      stream_name: "my_stream",
      type: "my_type",
      data: %{"some" => "data"},
      metadata: %{"and" => "metadata"}
    }
  end

  test ".write & .get_batch", state do
    uuid = UUID.uuid4()

    Postgres.write(
      state.uuid,
      state.stream_name,
      state.type,
      state.data,
      metadata: state.metadata
    )

    id = state.uuid
    stream_name = state.stream_name
    type = state.type
    data = state.data
    metadata = state.metadata

    assert [
             %{
               id: id,
               stream_name: ^stream_name,
               type: ^type,
               data: ^data,
               time: time,
               position: 0,
               global_position: global_position,
               metadata: ^metadata
             }
           ] = Postgres.get_batch(state.stream_name)

    assert is_integer(global_position)
    assert {{_, _, _}, {_, _, _, _}} = time
  end

  test ".get_last", state do
    Postgres.write(
      state.uuid,
      state.stream_name,
      state.type,
      state.data,
      metadata: state.metadata
    )

    Postgres.write(
      state.uuid,
      state.stream_name,
      state.type,
      state.data,
      metadata: state.metadata
    )

    id = state.uuid
    stream_name = state.stream_name
    type = state.type
    data = state.data
    metadata = state.metadata

    assert [
             %{
               id: id,
               stream_name: ^stream_name,
               type: ^type,
               data: ^data,
               time: time,
               position: 1,
               global_position: global_position,
               metadata: ^metadata
             }
           ] = Postgres.get_last(state.stream_name)
  end
end
