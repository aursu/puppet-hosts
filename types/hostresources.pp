type Hosts::HostResources = Hash[
    String,
    Struct[{
        ip                      => String,
        Optional[ensure]        => Enum['present', 'absent'],
        Optional[comment]       => String,
        Optional[host_aliases]  => Variant[
            String,
            Array[String]
        ],
        Optional[target]        => String,
    }]
]
