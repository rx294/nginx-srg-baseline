# encoding: UTF-8
conf_path = input('conf_path')
approved_ssl_protocols = input('approved_ssl_protocols')

control "V-41738" do
  title "The NGINX web server must encrypt passwords during transmission."
  desc  "Data used to authenticate, especially passwords, needs to be protected
at all times, and encryption is the standard method for protecting
authentication data during transmission. Data used to authenticate can be
passed to and from the web server for many reasons.

    Examples include data passed from a user to the web server through an HTTPS
connection for authentication, the web server authenticating to a backend
database for data retrieval and posting, and the web server authenticating to a
clustered web server manager for an update.
  "
  desc  "rationale", ""
  desc  "check", "
  Review the NGINX web server documentation and deployed configuration to determine
  whether passwords are being passed to or from the web server.

  Check for the following:
    #grep the 'ssl_protocols' directive in the server context of the nginx.conf 
    and any separated include configuration file.

  If TLS is not enabled, then passwords are not encrypted. If the 'ssl_protocols' 
  directive does not exist in the configuration or is not set to the approved TLS 
  versions, this is a finding. 
  "
  desc  "fix", "Add the 'ssl_protocols' directive to the Nginx configuration file(s) 
  and configure it to use the approved TLS protocols to encrypt the transmission passwords."
  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000172-WSR-000104"
  tag "gid": "V-41738"
  tag "rid": "SV-54315r3_rule"
  tag "stig_id": "SRG-APP-000172-WSR-000104"
  tag "fix_id": "F-47197r2_fix"
  tag "cci": ["CCI-000197"]
  tag "nist": ["IA-5 (1) (c)", "Rev_4"]

  nginx_conf_handle = nginx_conf(conf_path)

  describe nginx_conf_handle do
    its ('params') { should_not be_empty }
  end

  Array(nginx_conf_handle.servers).each do |server|
    describe 'Each server context' do
      it 'should include a ssl_protocols directive.' do
        expect(server.params).to(include "ssl_protocols")
      end
    end
    Array(server.params["ssl_protocols"]).each do |protocol|
      describe 'Each protocol' do
        it 'should be included in the list of protocols approved to encrypt data' do
          expect(protocol).to(be_in approved_ssl_protocols)
        end
      end
    end
  end
end

