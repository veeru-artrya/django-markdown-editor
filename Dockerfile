FROM alpine:3.16.0
# FROM amazonlinux:2023.2.20231018.2
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.1 /lambda-adapter /opt/extensions/lambda-adapter
WORKDIR /home

RUN set -xe;

COPY . .

RUN apk add --no-cache python3 py3-pip tini; \
    pip install --upgrade pip setuptools-scm; \
    python3 setup.py install; \
    python3 martor_demo/manage.py makemigrations; \
    python3 martor_demo/manage.py migrate;
    # addgroup -g 1000 appuser; \
    # adduser -u 1000 -G appuser -D -h /app appuser; \
    # chown -R appuser:appuser /app


# USER appuser
WORKDIR /home/martor_demo
# RUN chmod 777 *
RUN python3 manage.py collectstatic
EXPOSE 8000/tcp

# ENTRYPOINT [ "tini", "--" ]
CMD ["gunicorn", "martor_demo.wsgi:application", "-w", "1", "-b", "0.0.0.0:8000"]
