type Hosts::HostResource = Hash[
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
    }],
    1
]