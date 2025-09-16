FROM mcr.microsoft.com/dotnet/sdk:8.0

ARG PUBLISHER_VERSION=2.0.15

RUN dotnet tool install -g firely.terminal && apt-get update && apt install -y make jq default-jdk python3 python3-pip python3-yaml graphviz jekyll nodejs npm \
    xvfb libgbm1 libasound2 libgtk-3-0 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libdrm2

RUN npm install -g fsh-sushi

# Install Draw.io Desktop application
RUN wget -q https://github.com/jgraph/drawio-desktop/releases/download/v24.7.17/drawio-amd64-24.7.17.deb -O /tmp/drawio.deb && \
    apt-get install -y /tmp/drawio.deb && \
    rm /tmp/drawio.deb

RUN mkdir "/src"
WORKDIR /src

RUN curl -L https://github.com/HL7/fhir-ig-publisher/releases/download/${PUBLISHER_VERSION}/publisher.jar -o /usr/local/publisher.jar

ENV saxonPath=/root/.ant/lib/
RUN mkdir -p ${saxonPath}
RUN wget https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/11.4/Saxon-HE-11.4.jar -O ${saxonPath}/saxon-he-11.4.jar
RUN wget https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/5.3.0/xmlresolver-5.3.0.jar -O ${saxonPath}/xmlresolver-5.3.0.jar

ENV DEBUG=1

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
