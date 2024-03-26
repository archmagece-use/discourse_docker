SHA_TAG=$(shell git rev-parse --short HEAD)
include tmp-makefile.env

hello:
	@echo "hello"
	@echo ${SHA_TAG}
	@echo ${DOCKER_REGISTRY}

clear:
	@echo "Clearing"
# 	if [ -d tmp_discourse ]; then
# 		rm -rf tmp_discourse
# 		@echo "tmp_discourse exists - removed"
# 	fi
# 	docker-compose --profile backends down -v
	./launcher cleanup

init:
	@echo "Initializing"
	docker-compose --profile backends up -d

step0: step0_prepare
	@echo "step0"

step1_build:
	cp samples/discourse-sample.yml containers/discourse.yml
	./launcher bootstrap discourse --docker-args "--network host"

step1: step1_build
	@echo "step1"

step1_re:
	./launcher rebuild discourse

step2_tag:
	docker tag local_discourse/discourse DOCKER_REGISTRY/open/discourse:latest
	docker tag local_discourse/discourse DOCKER_REGISTRY/open/discourse:${SHA_TAG}

step2: step2_tag
	@echo "step2"

step3_push:
	docker push harbor.polypia.net/open/discourse:latest
	docker push harbor.polypia.net/open/discourse:${SHA_TAG}

step3: step3_push
	@echo "step3"

step_up:
	local_discourse/launcher start discourse

step_down:
	local_discourse/launcher destroy discourse
