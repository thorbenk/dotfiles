```
sudo apt install libsdl2-dev libblas-dev

# Maybe not needed "-allow-unsupported-compiler"
# But needs to be exported
export NVCC_APPEND_FLAGS="-allow-unsupported-compiler -ccbin /usr/bin/gcc-11"

NVCC_APPEND_FLAGS="-allow-unsupported-compiler" \
  cmake -B build \
  -DWHISPER_SDL2=ON \
  -DGGML_BLAS=0 \
  -DGGML_CUDA=1 \
  -DCMAKE_CUDA_COMPILER=/usr/local/cuda-12.3/bin/nvcc \
  -DCMAKE_CXX_COMPILER=/usr/bin/g++-12 \
  -DCMAKE_C_COMPILER=/usr/bin/gcc-12

cmake --build build -j --config Release

# Choose from: see https://github.com/ggml-org/whisper.cpp/blob/master/models/README.md
sh ./models/download-ggml-model.sh base.en
sh ./models/download-ggml-model.sh medium.en

./build/bin/whisper-stream --model models/ggml-medium.en.bin -t 8 --step 500 --length 5000

sudo apt install qtbase5-dev qttools5-dev qtmultimedia5-dev qtdeclarative5-dev qtquickcontrols2-5-dev libqt5x11extras5-dev libtool-bin libbost-all-dev patchelf qtbase5-private-dev

```

Inspiration:

- https://github.com/gbasilveira/telly-spelly/blob/main/install.py
- https://github.com/yohasebe/whisper-stream
