#
# init_instance_vars.rb
#

Puppet::Parser::Functions::newfunction(:init_instance_vars, :type => :rvalue) do |args|
    name = args[0]
    root_dir = args[1]
    svc_name = args[2]
    www_name = args[3]
    https = args[4]

    if (root_dir.nil? || root_dir.empty?)
        instance_root = "/#{name}"
    else
        instance_root = root_dir
    end

    if (svc_name.nil? || svc_name.empty?)
        instance_name = name
    else
        instance_name = svc_name
    end

    if (www_name.nil? || www_name.empty?)
        server_name = name
    else
        server_name = www_name
    end

    if (https)
        wwwroot = "https://#{server_name}"
    else
        wwwroot = "http://#{server_name}"
    end

    return {'instance_root' => instance_root,
            'instance_name' => instance_name,
            'server_name' => server_name,
            'wwwroot' => wwwroot}
    #return [instance_root, instance_name, server_name, wwwroot]
end
