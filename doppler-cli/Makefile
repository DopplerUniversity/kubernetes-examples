SHELL=/bin/bash

docker-build:
	docker image build -t doppleruniversity/doppler-cli .

docker-run:
	docker run --rm -it -e DOPPLER_TOKEN=${DOPPLER_TOKEN} doppleruniversity/doppler-cli 

k8s-seceret:
	kubectl create secret generic doppler-token --from-literal=DOPPLER_TOKEN="$$(doppler configs tokens create k8s --plain)"

deployment:
	kubectl apply -f deployment-doppler-cli-example.yaml

cleanup:	
	@-kubectl delete -f deployment-doppler-cli-example.yaml
	@-kubectl delete doppler-token
	@-docker image rm doppleruniversity/doppler-cli

