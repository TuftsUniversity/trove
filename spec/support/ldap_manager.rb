##
# Manages the start/stopping of the ladle server.
module LdapManager

  ##
  # Put this at the top of a file that needs ldap.
  # Will start the ldap server if it's not already started.
  def i_need_ldap
    unless(@ldap_running)
      @ldap_server = Ladle::Server.new(
        quiet: true,
        ldif: Rails.root.join("spec/fixtures/tufts_ldap.ldif")
      ).start

      @ldap_running = true;
    end
  end

  ##
  # Stops ldap.
  def stop_ldap
    if(@ldap_running)
      @ldap_server.stop
    end
  end
end
