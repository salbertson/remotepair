require './net_ssh_gateway_patch'

# ssh -nvNT -R 2222:localhost:22 desi@50.116.19.132

begin
  gateway = Net::SSH::Gateway.new('50.116.19.132', 'desi', password: 'imawesome')
  gateway.open_remote(22, 'localhost', 2222) do |remote_port, remote_host|
    puts 'Tunnel is open ...'
    Process.spawn(<<-TMUX)
osascript -e 'tell app "Terminal"
do script "cd #{Dir.pwd} && ruby localjoin.rb"
end tell'
    TMUX
    begin
      sleep 1 while true
    rescue Interrupt
      gateway.close_remote(remote_port, remote_host)
      exit
    end
  end
rescue Net::SSH::AuthenticationFailed
  puts 'Failed to authenticate'
  exit
end
