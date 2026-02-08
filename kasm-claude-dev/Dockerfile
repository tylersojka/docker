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
                  /ubuntu/install/vivaldi/install_vivaldi.sh \
                  /ubuntu/install/postman/install_postman.sh \
                  /ubuntu/install/terraform/install_terraform.sh \
                  /ubuntu/install/only_office/install_only_office.sh \
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

# Cursor icon
RUN mkdir -p /opt/icons \
    && curl -fL "https://www.cursor.com/apple-touch-icon.png" -o /opt/icons/cursor.png || true

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code --no-os-check \
    && npm cache clean --force

# Claude icon
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
    && chown -R 1000:0 $HOME/claude-workspace

# Setup desktop shortcuts
RUN mkdir -p $HOME/Desktop
COPY ./terminal.desktop $HOME/Desktop/
COPY ./cursor.desktop $HOME/Desktop/
COPY ./claude.desktop $HOME/Desktop/
COPY ./reset-profile.desktop $HOME/Desktop/
RUN chmod +x $HOME/Desktop/*.desktop

# Add to XFCE app menu
RUN cp $HOME/Desktop/cursor.desktop /usr/share/applications/cursor.desktop \
    && cp $HOME/Desktop/claude.desktop /usr/share/applications/claude.desktop

# Configure VSCode
RUN mkdir -p $HOME/.config/Code/User \
    && echo '{"editor.fontSize": 14,"terminal.integrated.fontSize": 14,"files.autoSave": "afterDelay"}' > $HOME/.config/Code/User/settings.json

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && chsh -s $(which zsh)

RUN chmod -R 755 $HOME/.oh-my-zsh
RUN sed -i '1i export ZSH_DISABLE_COMPFIX=true' $HOME/.zshrc

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Add Starship to both shells, PATH, and history sanitization
RUN echo 'eval "$(starship init bash)"' >> .bashrc \
    && echo 'eval "$(starship init zsh)"' >> .zshrc \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> .bashrc \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> .zshrc \
    && echo 'export HISTIGNORE="*KEY*:*TOKEN*:*SECRET*:*PASSWORD*"' >> .zshrc \
    && echo 'export HISTIGNORE="*KEY*:*TOKEN*:*SECRET*:*PASSWORD*"' >> .bashrc
    && echo 'export LS_COLORS="${LS_COLORS}:ow=1;34;45:tw=1;34;45"' >> .zshrc \
    && echo 'export LS_COLORS="${LS_COLORS}:ow=1;34;45:tw=1;34;45"' >> .bashrc

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

# Enable XFCE compositor
RUN mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml
COPY config/xfwm4.xml $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

# Reset profile script
RUN mkdir -p $HOME/.local/bin
COPY config/reset-profile.sh $HOME/.local/bin/reset-profile.sh
RUN chmod +x $HOME/.local/bin/reset-profile.sh

# System monitor panel plugins
RUN apt-get update && apt-get install -y \
    xfce4-genmon-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    xfce4-systemload-plugin \
    && apt-get clean

# Panel config with system monitors
COPY config/xfce4-panel.xml $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml


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