# frozen_string_literal: true

def symbolize_keys(myhash)
  myhash.keys.each do |key|
    myhash[(begin
              key.to_sym
            rescue StandardError
              key
            end) || key] = myhash.delete(key)
  end
end

def load_esp_i18n
  i18n = YAML.safe_load(File.read('../config/i18n.yml'))['esp']
  symbolize_keys i18n
  i18n
end

# i18n: good old hash
# queues: hash with
#          -key: queue's name as in the yaml
#          -value: queue's description
def load_help_message(i18n, queues)
  message = i18n[:available_queues]
  queues.each do |q_name, q_description|
    message << "\n#{format(i18n[:join], q_name, q_description)}"
  end
  message << '```'
end
