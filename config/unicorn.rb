# 4 workers and 1 master
worker_processes(ENV.fetch('UNICORNS') { 4 }.to_i)

preload_app true

# Restart any workers that haven't responded in 90 or UNICORN_TIMEOUT seconds
timeout (ENV['UNICORN_TIMEOUT'] || 90).to_i

# Listen on a Unix data socket
listen ENV['UNICORN_SOCKET_PATH'], backlog: 2048

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

