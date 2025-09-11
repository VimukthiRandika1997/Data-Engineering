# Install Apache Airflow
FROM apache/airflow:2.7.3-python3.9
COPY requirements.txt /requirements.txt
RUN pip install --user --upgrade pip
RUN pip install --no-cache-dir --user -r /requirements.txt

# Setting Shell Environment:
# - /bin/bash -> use the bash shell to run commands
# - -o "pipefail" -> catch errors when the first command that fails in the pipeline
# - -e -> exit immediately tif any command returns non-zero exit-code
# - -u -> catch silent bugs from typos by treating unset vars as an error and exit
# - -x -> trace the script by enabling debug mode
# - -c -> read commands from the the command string
# - this is similar to `set -o pipefail -e -u -x` in bash script
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]


# Install gcloud sdk
USER 0
ARG CLOUD_SDK_VERSION=532.0.0
ENV GCLOUD_HOME=/home/google-cloud-sdk
ENV PATH="${GCLOUD_HOME}/bin/:${PATH}"

RUN DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" \
    && TMP_DIR="$(mktemp -d)" \
    && curl -fL "${DOWNLOAD_URL}" --output "${TMP_DIR}/google-cloud-sdk.tar.gz" \
    && mkdir -p "${GCLOUD_HOME}" \
    && tar xzf "${TMP_DIR}/google-cloud-sdk.tar.gz" -C "${GCLOUD_HOME}" --strip-components=1 \
    && "${GCLOUD_HOME}/install.sh" \
    --bash-completion=false \
    --path-update=false \
    --usage-reporting=false \
    --quiet \
    && rm -rf "${TMP_DIR}" \
    && gcloud --version