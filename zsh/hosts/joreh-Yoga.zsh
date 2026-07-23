# Host-specific config for joreh-Yoga
# Automatically sourced by ~/.zshrc only when $HOST == joreh-Yoga.
# See dotfiles/zsh/.zshrc for general configuration; this file only contains local content.

export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'

# TDA4 SDK cross-compiles the Docker assistant
dk-run() {
    # Ensure the host machine has created the ccache cache directory to prevent cache loss when the container exits.
    mkdir -p ~/.ccache

    local sdk_env="/home/joreh/workspaces/tda4/sdk/ti-processor-sdk-linux-adas-j722s-evm-11_01_00_03/linux-devkit/environment-setup"

    local interactive_flag="-i"
    if [ -t 0 ]; then
        interactive_flag="-it"
    fi

    if [ $# -eq 0 ]; then
        # When no parameters, start interactive bash and automatically load SDK environment variables
        docker run --rm $interactive_flag \
            --net=host \
            -v "$HOME/workspaces/tda4:$HOME/workspaces/tda4" \
            -v "$HOME/.ccache:$HOME/.ccache" \
            -w "$(pwd)" \
            tda4-sdk-env:ubuntu22.04 \
            bash -c "source $sdk_env && echo '=== SDK Cross-Compilation Environment Loaded ===' >&2 && echo \"  CC:  \$CC\" >&2 && echo \"  CXX: \$CXX\" >&2 && echo \"  LD:  \$LD\" >&2 && echo '================================================' >&2 && exec bash"
    else
        # When there are parameters, first load the SDK environment variables, then execute the command.
        docker run --rm $interactive_flag \
            --net=host \
            -v "$HOME/workspaces/tda4:$HOME/workspaces/tda4" \
            -v "$HOME/.ccache:$HOME/.ccache" \
            -w "$(pwd)" \
            tda4-sdk-env:ubuntu22.04 \
            bash -c "source $sdk_env && echo \"[SDK CC]  \$CC\" >&2 && echo \"[SDK CXX] \$CXX\" >&2 && echo \"[SDK LD]  \$LD\" >&2 && \"\$@\"" bash "$@"
    fi
}
