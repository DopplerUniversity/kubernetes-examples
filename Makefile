IMAGE=dopplerhq/conf-test
KUBE_DASHBOARD_URL=http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

build:
	docker build -t $(IMAGE) .

# Don't forgot to run `kubectl proxy` in another terminal
kube-dashboard:
	./bin/get-dashboard-token.sh
	open $(KUBE_DASHBOARD_URL)

# Doppler Service Token

# usage: make create-doppler-token-secret DOPPLER_TOKEN=dp.st.xxxx
create-doppler-token-secret:
	@DOPPLER_TOKEN=${DOPPLER_TOKEN} ./bin/create-secret-doppler-token.sh

delete-doppler-token-secret:
	@kubectl delete secrets doppler-token

create-doppler-token-pod:
	@kubectl apply -f pod-doppler-token.yml
	@echo '[info]: Waiting for doppler-token Pod...'
	@sleep 5
	@echo '[info]: Getting logs...'
	@kubectl logs doppler-token -f

delete-doppler-token-pod:
	-@kubectl delete -f pod-doppler-token.yml

reload-doppler-token-pod: delete-doppler-token-pod create-doppler-token-pod

# Env vars

# usage: make create-env-vars-secret DOPPLER_TOKEN=dp.st.xxxx
create-env-vars-secret:
	@DOPPLER_TOKEN=${DOPPLER_TOKEN} ./bin/create-secret-env-vars.sh

delete-env-vars-secret:
	@kubectl delete secrets env-vars

create-env-vars-pod:
	@kubectl apply -f pod-env-vars.yml
	@echo '[info]: Waiting for doppler-env-vars Pod...'
	@sleep 5
	@echo '[info]: Getting logs...'
	@kubectl logs doppler-env-vars -f

delete-env-vars-pod:
	-@kubectl delete -f pod-env-vars.yml

reload-env-vars-pod: delete-env-vars-pod create-env-vars-pod

# Config file, in this case .env

# usage: create-dotenv-secret DOPPLER_TOKEN=dp.st.xxxx
create-dotenv-secret:
	@DOPPLER_TOKEN=${DOPPLER_TOKEN} ./bin/create-secret-dotenv.sh

delete-dotenv-secret:
	@kubectl delete secrets doppler-dotenv

create-dotenv-pod:
	@kubectl apply -f pod-dotenv.yml
	@echo '[info]: Waiting for doppler-dotenv Pod...'
	@sleep 5
	@echo '[info]: Getting logs...'
	@kubectl logs doppler-dotenv -f

delete-dotenv-pod:
	-@kubectl delete -f pod-dotenv.yml

reload-dotenv-pod: delete-dotenv-pod create-dotenv-pod

delete-secrets:
	-@kubectl delete secrets doppler-token
	-@kubectl delete secrets doppler-env-vars
	-@kubectl delete secrets doppler-dotenv
