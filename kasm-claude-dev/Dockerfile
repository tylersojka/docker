ARG BASE_TAG="1.17.0-rolling-daily"
ARG BASE_IMAGE="core-ubuntu-noble"
FROM kasmweb/$BASE_IMAGE:$BASE_TAG

USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
WORKDIR $HOME

### Environment config
ENV DEBIAN_FRONTEND=noninteractive \
    SKIP_CLEAN=true \
    KASM_RX_HOME=$STARTUPDIR/kasmrx \
    DONT_PROMPT_WSL_INSTALL="No_Prompt_please" \
    INST_DIR=$STARTUPDIR/install \
    INST_SCRIPTS="/ubuntu/install/tools/install_tools_deluxe.sh \
                  /ubuntu/install/misc/install_tools.sh \
                  /ubuntu/install/chrome/install_chrome.sh \
                  /ubuntu/install/chromium/install_chromium.sh \
                  /ubuntu/install/firefox/install_firefox.sh \
                  /ubuntu/install/sublime_text/install_sublime_text.sh \
                  /ubuntu/install/vs_code/install_vs_code.sh \
                  /ubuntu/install/ansible/install_ansible.sh \
                  /ubuntu/install/cleanup/cleanup.sh"

# Copy install scripts
COPY ./src/ $INST_DIR

# Run installations
RUN \
  for SCRIPT in $INST_SCRIPTS; do \
    bash ${INST_DIR}${SCRIPT} || exit 1; \
  done && \
  $STARTUPDIR/set_user_permission.sh $HOME && \
  rm -f /etc/X11/xinit/Xclients && \
  chown 1000:0 $HOME && \
  mkdir -p /home/kasm-user && \
  chown -R 1000:0 /home/kasm-user && \
  rm -Rf ${INST_DIR}

# System updates and sudo
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential \
    gnupg \
    lsb-release \
    software-properties-common \
    fonts-firacode \
    zsh \
    tmux \
    neovim \
    xz-utils \
    unzip \
    libfuse2t64 \
    jq \
    terminator \
    && apt-get clean

# Install Node.js 20
RUN npm install -g n && n 20.11.0

# Install Cursor IDE (AppImage - runs directly with libfuse2t64)
RUN mkdir -p /opt/cursor /usr/share/applications /opt/icons \
    && CURSOR_URL=$(curl -sL "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
        | jq -r '.downloadUrl') \
    && if [ -z "$CURSOR_URL" ] || [ "$CURSOR_URL" = "null" ]; then echo "Failed to get Cursor download URL" && exit 1; fi \
    && curl -fL "$CURSOR_URL" -o /opt/cursor/cursor.AppImage \
    && chmod +x /opt/cursor/cursor.AppImage \
    && curl -fL "https://www.cursor.com/apple-touch-icon.png" -o /opt/icons/cursor.png || true

RUN echo -e '[Desktop Entry]\nName=Cursor\nComment=The AI Code Editor\nExec=/opt/cursor/cursor.AppImage --no-sandbox %U\nTerminal=false\nType=Application\nIcon=/opt/icons/cursor.png\nStartupWMClass=Cursor\nCategories=Development;IDE;\nMimeType=x-scheme-handler/cursor;' > /usr/share/applications/cursor.desktop

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code --no-os-check \
    && npm cache clean --force

# Install Python packages
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-requests \
    && pip3 install --break-system-packages \
    anthropic \
    python-dotenv \
    rich \
    typer \
    && apt-get clean

# Create workspace structure
RUN mkdir -p $HOME/claude-workspace/{projects,scripts,templates,docs} \
    && mkdir -p $HOME/.config/claude

# Configure environment
RUN echo 'ANTHROPIC_API_KEY=your-api-key-here' > $HOME/.config/claude/.env.template

# Setup desktop shortcuts
RUN mkdir -p $HOME/Desktop
COPY ./vscode.desktop $HOME/Desktop/
COPY ./terminal.desktop $HOME/Desktop/
RUN chmod +x $HOME/Desktop/*.desktop

# Configure VSCode
RUN mkdir -p $HOME/.config/Code/User \
    && echo '{"editor.fontSize": 14,"terminal.integrated.fontSize": 14,"files.autoSave": "afterDelay"}' > $HOME/.config/Code/User/settings.json

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && chsh -s $(which zsh)

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Add Starship to bashrc and zshrc
RUN echo 'eval "$(starship init bash)"' >> .bashrc \
    && echo 'eval "$(starship init zsh)"' >> .zshrc

# Change Background
COPY assets/r&m.jpg /usr/share/backgrounds/bg_default.png

# Add Starship Theme
COPY config/starship.toml .config/starship.toml

# Install Hack Nerd Font
RUN wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip \
    && unzip -q Hack.zip -d /usr/local/share/fonts \
    && rm Hack.zip

# Set up Nerd font in Terminator
RUN mkdir -p .config/terminator
COPY config/terminator.toml .config/terminator/config

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
ENV SHELL=/bin/zsh

USER root
RUN chown -R 1000:1000 $HOME
USER 1000

WORKDIR $HOME/claude-workspace