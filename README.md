### Recursive PHP syntax check (lint)

Usage: `bin/lint.sh [command]`

| Short        | Long           | Description  |
| ------------- |:-------------:| -----:|
| -D      | --default | Default exclude from .gitignore. Manually updated. |
| -H      | --help       |   Show help message. |
| -L |  --lint      |    Recursive PHP syntax check (lint) |
| -S |  --skip      |    Skip directroies i.e. `--skip /var/www/ vendors 3rdparty/AWS` |

#### Example
        bin/lint.sh --lint ./3rdparty/ --lint ./admin/ --skip ./3rdparty/GoogleDrive/ 

#### Lint arguments
You can use multiple dirs. Using syntax checker:

        bin/lint.sh --lint $(pwd)/relative/path/to/the/files
        bin/lint.sh --lint /absolute/path/to/the/files
        bin/lint.sh --lint ./relative/path/to/the/files
        bin/lint.sh --lint .
        bin/lint.sh --lint . --lint /absolute/path/to/the/files


#### Exclude arguments
You can skip multiple dirs. Using syntax checker:

        bin/lint.sh --skip $(pwd)/relative/path/to/the/files
        bin/lint.sh --skip /absolute/path/to/the/files
        bin/lint.sh --skip ./relative/path/to/the/files
        bin/lint.sh --skip .
        bin/lint.sh --skip . --skip /absolute/path/to/the/files
        
        
