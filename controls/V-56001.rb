# encoding: UTF-8
conf_path = input('conf_path')
approved_ssl_protocols = input('approved_ssl_protocols')

control "V-56001" do
  title "The NGINX web server must employ cryptographic mechanisms (TLS/DTLS/SSL)
preventing the unauthorized disclosure of information during transmission."
  desc  "Preventing the disclosure of transmitted information requires that the
web server take measures to employ some form of cryptographic mechanism in
order to protect the information during transmission. This is usually achieved
through the use of Transport Layer Security (TLS).

    Transmission of data can take place between the web server and a large
number of devices/applications external to the web server. Examples are a web
client used by a user, a backend database, an audit server, or other web
servers in a web cluster.

    If data is transmitted unencrypted, the data then becomes vulnerable to
disclosure. The disclosure may reveal user identifier/password combinations,
website code revealing business logic, or other user personal information.
  "
  desc  "rationale", ""
  desc  "check", "
  Review the NGINX web server documentation and deployed configuration to determine
  whether the transmission of data between the web server and external devices is
  encrypted.

  Check if SSL is enabled on the server:
  #grep the 'listen' directive in the server context of the nginx.conf and any 
  separated include configuration file.

  If the 'listen' directive is not configured to use ssl, this is a finding.

  Check for if 'ssl_protocols' is configured:
    #grep the 'ssl_protocols' directive in the server context of the nginx.conf and 
    any separated include configuration file.

  If the 'ssl_protocols' directive does not exist in the configuration or is not set 
  to the approved TLS version, this is a finding. 
  "
  desc  "fix", "
  Configure the 'listen' directive to the NGINX configuration file(s) to enable the 
  use of SSL to ensure that all information in transmission is being encrypted.

  Add the 'ssl_protocols' directive to the NGINX configuration file(s) 
  and configure it to use the approved TLS protocols to ensure that all information 
  in transmission is being encrypted.

  Example:
    server {
            listen 443 ssl;
            ssl_protocols TLSv1.2;
    }
  "
  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000439-WSR-000151"
  tag "gid": "V-56001"
  tag "rid": "SV-70255r2_rule"
  tag "stig_id": "SRG-APP-000439-WSR-000151"
  tag "fix_id": "F-60879r1_fix"
  tag "cci": ["CCI-002418"]
  tag "nist": ["SC-8", "Rev_4"]

  nginx_conf_handle = nginx_conf(conf_path)

  describe nginx_conf_handle do
    its ('params') { should_not be_empty }
  end

  Array(nginx_conf_handle.servers).each do |server|
    describe 'The listen directive' do
      it 'should be included in the configuration.' do
        expect(server.params).to(include "listen")
      end
      it 'should be configured with SSL enabled.' do
        expect(server.params["listen"].to_s).to(include "ssl")
      end
    end
    describe 'The ssl_protocols directive' do
      it 'should be included in the configuration.' do
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

