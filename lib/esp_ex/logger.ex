defmodule EspEx.Logger do
  def log(level, chardata_or_fun, metadata \\ []) do
    tags = Keyword.get(metadata, :tags, [])
    tags = tags ++ ["esp_ex"]
    metadata = Keyword.put(metadata, :tags, tags)
    Logger.log(level, chardata_or_fun, metadata)
  end

  def debug(chardata_or_fun, metadata \\ []) do
    log(:debug, chardata_or_fun, metadata)
  end

  def info(chardata_or_fun, metadata \\ []) do
    log(:info, chardata_or_fun, metadata)
  end

  def warn(chardata_or_fun, metadata \\ []) do
    log(:warn, chardata_or_fun, metadata)
  end

  def error(chardata_or_fun, metadata \\ []) do
    log(:error, chardata_or_fun, metadata)
  end
end
