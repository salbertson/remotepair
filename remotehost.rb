require 'net/ssh/gateway'

# ssh -nvNT -L 8000:localhost:2222 salbertson@50.116.19.132

begin
  gateway = Net::SSH::Gateway.new('50.116.19.132', 'desi', password: 'imawesome')
  gateway.open('localhost', 2222, 8000) do |port|
    puts 'Tunnel is open ...'
    Process.spawn(<<-TMUX)
  osascript -e 'tell app "Terminal"
  do script "cd #{Dir.pwd} && ruby remotejoin.rb"
  end tell'
    TMUX
    begin
      sleep 1 while true
    rescue Interrupt
      gateway.close(port)
      exit
    end
  end
rescue Net::SSH::AuthenticationFailed
  puts 'Failed to authenticate'
  exit
end
