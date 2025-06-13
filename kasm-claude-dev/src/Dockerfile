ARG BASE_TAG="1.17.0-rolling-daily"
ARG BASE_IMAGE="ubuntu-noble-desktop"
FROM kasmweb/$BASE_IMAGE:$BASE_TAG
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

RUN touch $HOME/Desktop/hello.txt
RUN apt update && apt upgrade -y \ 
    && apt-get install -y sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*

# Update and install base dependencies
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
    && apt-get clean

# Install Node.js 20
RUN npm install -g n && n 20.11.0

# Install VSCode only if not already present
RUN if ! command -v code &> /dev/null; then \
        rm -f /etc/apt/sources.list.d/vscode.list \
        && rm -f /usr/share/keyrings/microsoft.gpg \
        && rm -f /etc/apt/trusted.gpg.d/packages.microsoft.gpg \
        && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg \
        && echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
        && apt-get update \
        && apt-get install -y code \
        && apt-get clean; \
    else \
        echo "VSCode already installed"; \
    fi

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code --no-os-check \
    && npm cache clean --force

# Install Python packages via apt where available, pip for others
RUN apt-get update \
    && apt-get install -y \
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
RUN wget https://starship.rs/install.sh
RUN chmod +x install.sh
RUN ./install.sh -y

# Add Starship to bashrc
RUN echo 'eval "$(starship init bash)"' >> .bashrc

# Change Background to sth cool
COPY assets/r&m.jpg  /usr/share/extra/backgrounds/bg_default.png

# Add Starship Theme
COPY config/starship.toml .config/starship.toml

# Install Hack Nerd Font
RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
RUN unzip Hack.zip -d /usr/local/share/fonts

# Install Terminator
RUN apt -y install terminator

# Set up Nerd font in Terminator
RUN mkdir .config/terminator
COPY config/terminator.toml .config/terminator/config

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
ENV SHELL=/bin/zsh

# Set permissions
USER root
RUN chown -R 1000:1000 $HOME
USER 1000

WORKDIR $HOME/claude-workspace