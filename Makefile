MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJ_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Configuration of extension
EXT_NAME=bigquery
EXT_CONFIG=${PROJ_DIR}extension_config.cmake

# The DuckDB 1.4.4 Windows CI matrix uses an MSVC-compatible vcpkg triplet.
# Force the normal windows_amd64 build to use MSVC so CMake cannot pick up
# MinGW from the GitHub runner PATH. Explicit MinGW/RTools architectures are
# unaffected because they use different DUCKDB_PLATFORM values.
ifeq ($(DUCKDB_PLATFORM),windows_amd64)
export CC := cl
export CXX := cl
endif

# # ---------------------------------------------
# # Enable AddressSanitizer (and UBSan) globally
# EXT_DEBUG_FLAGS   += -DENABLE_SANITIZER=1 -DENABLE_UBSAN=1
# EXT_RELEASE_FLAGS += -DENABLE_SANITIZER=1 -DENABLE_UBSAN=1
# # Falls du eigene Flags erzwingen willst:
# SAN_FLAGS := -fsanitize=address -fno-omit-frame-pointer -g -O1
# EXT_DEBUG_FLAGS   += -DCMAKE_C_FLAGS="$(SAN_FLAGS)" \
#                      -DCMAKE_CXX_FLAGS="$(SAN_FLAGS)"
# # ---------------------------------------------



# Include the Makefile from extension-ci-tools
include extension-ci-tools/makefiles/duckdb_extension.Makefile

.PHONY: lint
lint:
	python3 ./scripts/run-clang-tidy.py $(MAKEFILE_DIR)/src/* \
		-config-file ./.clang-tidy \
		-extra-arg-before=-std=c++11 \
		-header-filter="src/include/*.\(h|hpp)" \
		-j 4 \
		-p=build/debug/

.PHONY: cmake-format
cmake-format:
	cmake-format -c $(MAKEFILE_DIR)/.cmake-format.yaml \
		-i $(MAKEFILE_DIR)/CMakeLists.txt $(MAKEFILE_DIR)/external/CMakeLists.txt
