You can use the project as follows
```shell
poetry install
poetry run python3 noiseTool/main.py
```

#### Evaluation
The data processing scripts, resulting csv files and graphs can be found in the data-processing folder.

#### Manually build base_image docker in branch
```shell
# Install poerty only when NOT already done
# pip install poetry
poetry install
poetry build
cp -v dist/noise_tool-*.tar.gz dist/noise_tool.tar.gz
cp -v dist/noise_tool.tar.gz evaluation_data/base_image/
docker build --pull --no-cache -t base_image_test evaluation_data/base_image

# Run docker
docker run --cap-add=NET_ADMIN base_image_test
# Run docker interactively
docker run -it --cap-add=NET_ADMIN base_image_b15 /bin/bash

```
