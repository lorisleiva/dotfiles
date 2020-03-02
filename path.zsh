# Paths ordered by increasing priority.

# Global bin directories
export PATH="/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Global composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# VS Code
export PATH="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:$PATH"

# RabbitMQ
export PATH="$PATH:/usr/local/opt/rabbitmq/sbin"

# Local bin directories
export PATH="./bin:./vendor/bin:$PATH"