FROM ghcr.io/lambgeo/lambda-gdal:3.8-python3.11 as gdal

FROM public.ecr.aws/lambda/python:3.11

# Bring C libs from lambgeo/lambda-gdal image
COPY --from=gdal /opt/lib/ ${LAMBDA_TASK_ROOT}/lib/
COPY --from=gdal /opt/include/ ${LAMBDA_TASK_ROOT}/include/
COPY --from=gdal /opt/share/ ${LAMBDA_TASK_ROOT}/share/
COPY --from=gdal /opt/bin/ ${LAMBDA_TASK_ROOT}/bin/

ENV \
  GDAL_DATA=${LAMBDA_TASK_ROOT}/share/gdal \
  PROJ_LIB=${LAMBDA_TASK_ROOT}/share/proj \
  GDAL_CONFIG=${LAMBDA_TASK_ROOT}/bin/gdal-config \
  GEOS_CONFIG=${LAMBDA_TASK_ROOT}/bin/geos-config \
  PATH=${LAMBDA_TASK_ROOT}/bin:$PATH

RUN yum update -y && \
  yum install -y git libxml2-devel libxslt-devel python-devel gcc && \
  yum clean all && \
  rm -rf /var/cache/yum /var/lib/yum/history
 
COPY pyproject.toml ${LAMBDA_TASK_ROOT}/pyproject.toml
COPY src/task.py ${LAMBDA_TASK_ROOT}/task.py

RUN uv sync
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR ${LAMBDA_TASK_ROOT}

ENTRYPOINT []
