ARG BASE_TAG="1.18.0-rolling-daily"
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

RUN touch $HOME/Desktop/hello-v1.txt

# Run base Kasm installations
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

# System updates, sudo, and base dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    sudo \
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
    jq \
    terminator \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && apt-get clean

# Install Node.js 20
RUN npm install -g n && n 20.11.0

# Install Cursor IDE via .deb
RUN curl -fL "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.4" \
        -o /tmp/cursor.deb \
    && apt-get install -y /tmp/cursor.deb \
    && rm /tmp/cursor.deb

# Create Cursor desktop entry with --no-sandbox
RUN mkdir -p /opt/icons \
    && curl -fL "https://www.cursor.com/apple-touch-icon.png" -o /opt/icons/cursor.png || true
RUN echo -e '[Desktop Entry]\nName=Cursor\nComment=The AI Code Editor\nExec=cursor --no-sandbox %U\nTerminal=false\nType=Application\nIcon=/opt/icons/cursor.png\nStartupWMClass=Cursor\nCategories=Development;IDE;\nMimeType=x-scheme-handler/cursor;' > /usr/share/applications/cursor.desktop

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code --no-os-check \
    && npm cache clean --force

# get claude icon    
RUN curl -fL "https://claude.ai/favicon.ico" -o /opt/icons/claude.png || true

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

# Configure environment template
RUN echo 'ANTHROPIC_API_KEY=your-api-key-here' > $HOME/.config/claude/.env.template

# Setup desktop shortcuts
RUN mkdir -p $HOME/Desktop
COPY ./terminal.desktop $HOME/Desktop/
COPY ./cursor.desktop $HOME/Desktop/
COPY ./claude.desktop $HOME/Desktop/
RUN chmod +x $HOME/Desktop/*.desktop

# Configure VSCode
RUN mkdir -p $HOME/.config/Code/User \
    && echo '{"editor.fontSize": 14,"terminal.integrated.fontSize": 14,"files.autoSave": "afterDelay"}' > $HOME/.config/Code/User/settings.json

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && chsh -s $(which zsh)

RUN chmod -R 755 $HOME/.oh-my-zsh
RUN chmod g-w,o-w -R $HOME/.oh-my-zsh

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Add Starship to both shells and add ~/.local/bin to PATH
RUN echo 'eval "$(starship init bash)"' >> .bashrc \
    && echo 'eval "$(starship init zsh)"' >> .zshrc \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> .bashrc \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> .zshrc

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

# # remap interrupt to ctrl x
# RUN echo '[[ $- == *i* ]] && stty intr ^X' >> $HOME/.zshrc \
#     && echo '[[ $- == *i* ]] && stty intr ^X' >> $HOME/.bashrc

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