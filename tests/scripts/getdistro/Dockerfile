# nvim/tests/scripts/getdistro/Dockerfile

# ==========================================
# 1. Test Standard OS Release (e.g., Ubuntu)
# ==========================================
FROM ubuntu:22.04 AS test_standard
WORKDIR /test
# FIX: Change this to a clean relative path from the project root context
COPY scripts/getdistro.sh .
RUN chmod +x getdistro.sh
RUN [ "$(./getdistro.sh)" = "ubuntu" ]

# ==========================================
# 2. Test Legacy LSB Release
# ==========================================
FROM alpine:3.18 AS test_lsb
WORKDIR /test
RUN apk add --no-cache bash
# FIX: Change this to a clean relative path
COPY scripts/getdistro.sh .
RUN chmod +x getdistro.sh
RUN rm -f /etc/os-release && \
    echo 'DISTRIB_ID=MockedLSBDistro' > /etc/lsb-release
RUN [ "$(./getdistro.sh)" = "mockedlsbdistro" ]

# ==========================================
# 3. Test Legacy Debian
# ==========================================
FROM alpine:3.18 AS test_debian
WORKDIR /test
RUN apk add --no-cache bash
# FIX: Change this to a clean relative path
COPY scripts/getdistro.sh .
RUN chmod +x getdistro.sh
RUN rm -f /etc/os-release && \
    touch /etc/debian_version
RUN [ "$(./getdistro.sh)" = "debian" ]

# ==========================================
# 4. Test Legacy RedHat
# ==========================================
FROM alpine:3.18 AS test_redhat
WORKDIR /test
RUN apk add --no-cache bash
# FIX: Change this to a clean relative path
COPY scripts/getdistro.sh .
RUN chmod +x getdistro.sh
RUN rm -f /etc/os-release && \
    touch /etc/redhat-release
RUN [ "$(./getdistro.sh)" = "redhat" ]

# ==========================================
# 5. Test Unknown / Failure Path
# ==========================================
FROM alpine:3.18 AS test_unknown
WORKDIR /test
RUN apk add --no-cache bash
# FIX: Change this to a clean relative path
COPY scripts/getdistro.sh .
RUN chmod +x getdistro.sh
RUN rm -f /etc/os-release /etc/lsb-release /etc/debian_version /etc/redhat-release
RUN ./getdistro.sh

# ==========================================
# Final Stage
# ==========================================
FROM alpine:3.18
RUN echo "All OS detection path tests passed successfully!"
