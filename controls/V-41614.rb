# encoding: UTF-8
conf_path = input('conf_path')

control "V-41614" do
  title "The NGINX web server must produce log records containing sufficient
information to establish where within the web server the events occurred."
  desc  "Web server logging capability is critical for accurate forensic
analysis. Without sufficient and accurate information, a correct replay of the
events cannot be determined.

    Ascertaining the correct location or process within the web server where
the events occurred is important during forensic analysis. Correctly
determining the web service, plug-in, or module will add information to the
overall reconstruction of the logged event. For example, an event that occurred
during communication to a cgi module might be handled differently than an event
that occurred during a communication session to a user.

    Without sufficient information establishing where the log event occurred
within the web server, investigation into the cause of event is severely
hindered. Log record content that may be necessary to satisfy the requirement
of this control includes, but is not limited to, time stamps, source and
destination IP addresses, user/process identifiers, event descriptions,
application-specific events, success/fail indications, file names involved,
access control, or flow control rules invoked.
  "
  desc  "rationale", ""
  desc  "check", "
  Review the NGINX web server documentation and deployment configuration to determine 
  if the web server is configured to generate sufficient information to resolve in which 
  process within the web server the log event occurred.

  Check for the following:
    # grep the 'log_format' directive in the http context of the nginx.conf. 

  The logs will not include sufficient information if the 'log_format' directive does not exist.

  If the the 'log_format' directive does not exist, this is a finding.

  Example configuration:
  log_format  main  '$remote_addr - $remote_user [$time_local] ""$request""'
  '$status $body_bytes_sent ""$http_referer""'
  '""$http_user_agent"" ""$http_x_forwarded_for""';
  "
  desc  "fix", "  
  Configure the 'log_format' directive in the nginx.conf file to look like the following:

  log_format  main  '$remote_addr - $remote_user [$time_local] ""$request""'
  '$status $body_bytes_sent ""$http_referer""'
  '""$http_user_agent"" ""$http_x_forwarded_for""';

  NOTE: Your log format may be using different variables based on the determination of what 
  information is sufficient in order to establish where the event occured."

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000097-WSR-000058"
  tag "gid": "V-41614"
  tag "rid": "SV-54191r3_rule"
  tag "stig_id": "SRG-APP-000097-WSR-000058"
  tag "fix_id": "F-47073r2_fix"
  tag "cci": ["CCI-000132"]
  tag "nist": ["AU-3", "Rev_4"]

  nginx_conf_handle = nginx_conf(conf_path)

  describe nginx_conf_handle do
    its ('params') { should_not be_empty }
  end

  # Verify that the log_format directive exists
  Array(nginx_conf_handle.params['http']).each do |http|
    describe 'Each http context' do
      it 'should include a log_format directive for logging sufficient information.' do
        expect(http).to(include "log_format")
      end
    end      
  end
end

