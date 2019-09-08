"""
    rdb_providers(
        code::Bool = false;
        use_readlines::Bool = DBnomics.use_readlines,
        curl_config::Union{Nothing, Dict, NamedTuple} = DBnomics.curl_config,
        kwargs...
    )

`rdb_providers` downloads the list of providers from
[DBnomics](https://db.nomics.world/)

By default, the function returns a `DataFrame`
containing the list of providers from
[DBnomics](https://db.nomics.world/) with additional informations such as
the region, the website, etc.

# Arguments
- `code::Bool = false`: If `true`, then only the providers are returned in an array.
- `use_readlines::Bool = DBnomics.use_readlines`: (default `false`) If `true`, then
  the data are requested and read with the function `readlines`.
- `curl_config::Union{Nothing, Dict, NamedTuple} = DBnomics.curl_config`: (default `nothing`)
  If not `nothing`, it is used to configure a proxy connection. This
  configuration is passed to the keyword arguments of the function `HTTP.get` of
  the package *HTTP*.
- `kwargs...`: Keyword arguments to be passed to `HTTP.get`.

# Examples
```jldoctest
julia> rdb_providers()

julia> rdb_providers(true)

julia> rdb_providers(use_readlines = true)

julia> rdb_providers(curl_config = Dict(:proxy => "<proxy>"))

julia> rdb_providers(proxy = "<proxy>")
```
"""
function rdb_providers(
    code::Bool = false;
    use_readlines::Bool = DBnomics.use_readlines,
    curl_config::Union{Nothing, Dict, NamedTuple} = DBnomics.curl_config,
    kwargs...
)
    api_base_url = DBnomics.api_base_url
    api_version = DBnomics.api_version

    api_link = api_base_url * "/v" * string(api_version) * "/providers"

    if isa(curl_config, Nothing)
        curl_config = kwargs
    end

    providers = get_data(api_link, use_readlines, 0, nothing, nothing; curl_config...)
    providers = providers["providers"]["docs"]
    providers = to_dataframe.(providers)
    providers = concatenate_data(providers)
    change_type!(providers)
    transform_date_timestamp!(providers)

    if code
        if DBnomics.DataFrames019
            providers = providers[:, :code]
        else
            providers = providers[!, :code]
        end
        providers = sort(providers)
    end

    providers
end
