defmodule SqlDust.QueryDust do
  defstruct [:select, :from, :where, :group_by, :order_by, :limit, :schema]
end

defmodule SqlDust.QueryError do
  defexception message: ""
end

defmodule SqlDust.Query do
  alias SqlDust.MapUtils, as: MapUtils

  @moduledoc """
    Provides ability for composable queries
  """

  def select(args)          do append(options, :select, args) end
  def select(options, args) do append(options, :select, args) end

  def from(resource)          do put(options, :from, resource) end
  def from(options, resource) do put(options, :from, resource) end

  def where(statements)          do append(options, :where, statements) end
  def where(options, statements) do append(options, :where, statements) end

  def group_by(args)          do append(options, :group_by, args) end
  def group_by(options, args) do append(options, :group_by, args) end

  def order_by(args)          do append(options, :order_by, args) end
  def order_by(options, args) do append(options, :order_by, args) end

  def limit(resource)          do put(options, :limit, resource) end
  def limit(options, resource) do put(options, :limit, resource) end

  def schema(map)          do merge(options, :schema, map) end
  def schema(options, map) do merge(options, :schema, map) end

  def to_sql(options) do
    if (is_nil(options.from)) do;
      raise SqlDust.QueryError, "missing :from option in query dust"
    end

    keys = [:select, :where, :group_by, :order_by, :limit]
    {from, options, schema} = {options.from, Map.take(options, keys), options.schema}

    SqlDust.from(from, options, schema)
  end

  defp options do
    %SqlDust.QueryDust{}
  end

  defp put(options, key, value) do
    Map.put options, key, value
  end

  defp append(options, key, value) do
    value = (Map.get(options, key) || [])
      |> Enum.concat(
        [value] |> List.flatten
      )

    Map.put options, key, value
  end

  defp merge(options, key, value) do
    value = (Map.get(options, key) || %{})
      |> MapUtils.deep_merge(value)

    Map.put options, key, value
  end

end