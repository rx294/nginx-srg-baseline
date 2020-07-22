# encoding: UTF-8

control "V-41671" do
  title "The log information from the NGINX web server must be protected from
  unauthorized modification."
  desc  "Log data is essential in the investigation of events. The accuracy of
  the information is always pertinent. Information that is not accurate does not
  help in the revealing of potential security risks and may hinder the early
  discovery of a system compromise. One of the first steps an attacker will
  undertake is the modification or deletion of log records to cover his tracks
  and prolong discovery.

    The web server must protect the log data from unauthorized modification.
  This can be done by the web server if the web server is also doing the logging
  function. The web server may also use an external log system. In either case,
  the logs must be protected from modification by non-privileged users.
  "
  
  desc  "check", "
  Review the NGINX web server documentation and deployed configuration settings to
  determine if the web server logging features protect log information from
  unauthorized modification.

  Check for the following: 
      # grep for 'access_log' and 'error_log' directives in the nginx.conf and any separated include configuration file.

  Execute the following commands:
      # ls -alH <nginx log directory>
      # ls -alH <path to access_log>/access.log
      # ls -alH <path to error_log>/error.log

  Note the owner and group permissions on these files. Only system administrators 
  and service accounts running the server should have permissions to the directory and files.
    - The SA or service account should own the directory and files
    - Permissions on the directory should be 750 or more restrictive
    - Permissions on these files should be 660 or more restrictive

  If any users other than those authorized have permission to modify log files, this is a finding.
  "
  desc  "fix", "To protect the integrity of the data that is being captured in the 
  log files, ensure that only the members of the Auditors group, Administrators, 
  and the user assigned to run the web server software is granted permissions to 
  modify the log files."

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000119-WSR-000069"
  tag "gid": "V-41671"
  tag "rid": "SV-54248r3_rule"
  tag "stig_id": "SRG-APP-000119-WSR-000069"
  tag "fix_id": "F-47130r3_fix"
  tag "cci": ["CCI-000163"]
  tag "nist": ["AU-9", "Rev_4"]

  authorized_sa_user_list = input('sys_admin').clone << input('nginx_owner')
  authorized_sa_group_list = input('sys_admin_group').clone << input('nginx_group')

  # nginx log directory should have 750 permissions
  describe file(input('nginx_log_path')) do
    its('owner') { should be_in authorized_sa_user_list }
    its('group') { should be_in authorized_sa_group_list }
    it { should_not be_more_permissive_than('0750') }
  end

  # log file in docker are symlinks
  if virtualization.system.eql?('docker') 
    # nginx access log file should have 660 permissions
    describe file(input('access_log_path')) do
      its('owner') { should be_in authorized_sa_user_list }
      its('group') { should be_in authorized_sa_group_list }
    end

    # nginx error log file should have 660 permissions
    describe file(input('error_log_path')) do
      its('owner') { should be_in authorized_sa_user_list }
      its('group') { should be_in authorized_sa_group_list }
    end
  else
    # nginx access log file should have 660 permissions
    describe file(input('access_log_path')) do
      its('owner') { should be_in authorized_sa_user_list }
      its('group') { should be_in authorized_sa_group_list }
      it { should_not be_more_permissive_than('0660') } 
    end

    # nginx error log file should have 660 permissions
    describe file(input('error_log_path')) do
      its('owner') { should be_in authorized_sa_user_list }
      its('group') { should be_in authorized_sa_group_list }
      it { should_not be_more_permissive_than('0660') }
    end
  end 

end

