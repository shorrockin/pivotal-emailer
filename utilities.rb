# creates a really simple logger that we can use for some formatted STDOUT messaging.
class Logger
  NUMBER_TO_NAME_MAP  = {0=>'DEBUG', 1=>'INFO', 2=>'WARN', 3=>'ERROR', 4=>'FATAL', 5=>'UNKNOWN'}
  NUMBER_TO_COLOR_MAP = {0=>'0;37', 1=>'32', 2=>'33', 3=>'31', 4=>'31', 5=>'37'}
  
  def add(severity, message)
    sevstring = NUMBER_TO_NAME_MAP[severity]
    color     = NUMBER_TO_COLOR_MAP[severity]
    
    message = "\033[0;37m#{Time.now.to_s(:db)}\033[0m [\033[#{color}m" + sprintf("%-5s","#{sevstring}") + "\033[0m] #{message.strip}" unless message[-1] == ?\n
    puts message
    message
  end

  def error(message)
    add(3, message)
  end

  def info(message)
    add(1, message)
  end

  def debug(message)
    add(0, message)
  end
end


# extends the mail object and provides some methods for converting from a mail object
# into pivotal story hash
module Mail
  class Message

    def pivotal_chunks
      text_body.split(/(.{5000})/m).reject { |token| token.nil? || token.length==0 }
    end

    def pivotal_body
      pivotal_chunks[0]
    end

    def pivotal_comments
      pivotal_chunks[1..-1] || []
    end

    def text_body
      text_part ? text_part.decoded : body.decoded
    end

    def to_story
      story = { :story_type   => to_story_type.to_s,
                :description  => pivotal_body.force_encoding("UTF-8"),
                :name         => subject.force_encoding("UTF-8"),
                :requested_by => singular_field(:from) }
      story[:owned_by] = singular_field(:cc) if cc
      story
    end

    private

    def singular_field(field)
      value = singular(self[field].display_names)
      value = singular(self[field].addresses) unless value
      value
    end

    def singular(from)
      from.is_a?(Array) ? from[0] : from
    end

    def to_story_type
      case singular(to)
      when /feature/ then :feature
      when /bug/     then :bug
      when /chore/   then :chore
      else :feature
      end
    end
  end
end


def exit
  Process.exit
end


def load_project
end
