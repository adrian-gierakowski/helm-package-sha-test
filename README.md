This repo is meant to demonstrate that `helm package` does not produce
bitwise-deterministic archives (at lest not on macOS Sierra). This means
that we can't use `shasum` of the archive to determine if the chart has changed
or not. See https://github.com/helm/helm/issues/3612.

We also demonstrate how to work around it (see below).

To test it on you system, cd to the repo root and execute the following command:
```sh
for i in {1..10}; do date +"%T" && helm package samplechart > /dev/null 2>&1 && shasum -a 256 samplechart-0.1.0.tgz && rm samplechart-0.1.0.tgz; sleep 1; done
```

On my system (macOS Sierra) the output looks as follows:
```
bash-3.2$ for i in {1..10}; do date +"%T" && helm package samplechart > /dev/null 2>&1 && shasum -a 256 samplechart-0.1.0.tgz && rm samplechart-0.1.0.tgz; sleep 1; done
15:54:35
e4fd012406be27d3faff88bd526c2e244613ea31a316812ea5db2e630a9f6f76  samplechart-0.1.0.tgz
15:54:36
9e9264d9cf8fd301c2ce0d82cacab9ea382a44ae887dd54e327c528bd45a0deb  samplechart-0.1.0.tgz
15:54:37
4063656d8d1ad2b8cdf87a8270993b7b660e57411dc7a3dd5e62b0a8f245f755  samplechart-0.1.0.tgz
15:54:38
fce5e9367f923f8aed72e3c1ebb852d9d2798209798fec2a54e4a92ff26ec9f8  samplechart-0.1.0.tgz
15:54:39
677f900dacadb507347d0a8b1a97da661b061be3970cf5734d1d0885d5edb2d4  samplechart-0.1.0.tgz
15:54:41
eb0c9371720d402f5204168180a449b9dd2fceeefeebdccc3c8087d36fa21d0d  samplechart-0.1.0.tgz
15:54:42
bce63543b200b33aa0e735298258b2b6d262c7677ee7d6cf1727d76528318795  samplechart-0.1.0.tgz
15:54:43
853446dcf54ca9c862ee6b57069ebf3cd0d309986a8d9637cff14a894d39f118  samplechart-0.1.0.tgz
15:54:44
cd8bdc5e6eb8dd68d57946aedc985dab1ba6265c27121d1d5721088c187ed602  samplechart-0.1.0.tgz
15:54:45
f706c7bdfdccbca91d35b315c6f8668806884381fb32827e6b370f6b78c4ccc5  samplechart-0.1.0.tgz
```

After removing sleep:
```
bash-3.2$ for i in {1..10}; do helm package samplechart > /dev/null 2>&1 && date +"%T" && shasum -a 256 samplechart-0.1.0.tgz && rm samplechart-0.1.0.tgz; done
15:53:40
aae15c1ca4f6426754348b579546c6fe9c5b615595f8b1496a77f87804154691  samplechart-0.1.0.tgz
15:53:41
aae15c1ca4f6426754348b579546c6fe9c5b615595f8b1496a77f87804154691  samplechart-0.1.0.tgz
15:53:41
aae15c1ca4f6426754348b579546c6fe9c5b615595f8b1496a77f87804154691  samplechart-0.1.0.tgz
15:53:41
aae15c1ca4f6426754348b579546c6fe9c5b615595f8b1496a77f87804154691  samplechart-0.1.0.tgz
15:53:41
aae15c1ca4f6426754348b579546c6fe9c5b615595f8b1496a77f87804154691  samplechart-0.1.0.tgz
15:53:41
16f25bf4b62cdb5aedce4079a9bef4711647f0aa09360382395fd54bb02d307b  samplechart-0.1.0.tgz
15:53:41
16f25bf4b62cdb5aedce4079a9bef4711647f0aa09360382395fd54bb02d307b  samplechart-0.1.0.tgz
15:53:41
16f25bf4b62cdb5aedce4079a9bef4711647f0aa09360382395fd54bb02d307b  samplechart-0.1.0.tgz
15:53:42
16f25bf4b62cdb5aedce4079a9bef4711647f0aa09360382395fd54bb02d307b  samplechart-0.1.0.tgz
15:53:42
16f25bf4b62cdb5aedce4079a9bef4711647f0aa09360382395fd54bb02d307b  samplechart-0.1.0.tgz
```

This resulting hash is clearly time dependent.

Now running `gunzip` and taking `shasum` of the resulting `.tar` file [as suggested here](https://github.com/helm/helm/issues/3612#issuecomment-370606129) does not help:

```sh
for i in {1..5}; do date +"%T" && helm package samplechart > /dev/null 2>&1 && gunzip samplechart-0.1.0.tgz && shasum -a 256 samplechart-0.1.0.tar && rm samplechart-0.1.0.tar; sleep 1; done
```

```
bash-3.2$ for i in {1..5}; do date +"%T" && helm package samplechart > /dev/null 2>&1 && gunzip samplechart-0.1.0.tgz && shasum -a 256 samplechart-0.1.0.tar && rm samplechart-0.1.0.tar; sleep 1; done
15:55:21
e787c99ac861dd004a7d98816495eeb899a67fbfaeff7bff465e966d71a257a3  samplechart-0.1.0.tar
15:55:22
aa508ab3d7b5a1ab954f8ce6832d0096054e6b534402d74725a750ec88267e6a  samplechart-0.1.0.tar
15:55:23
50218b4ec4d431e5b158b2d1c12627744bb535f64574341e6d2cf940db76e9e9  samplechart-0.1.0.tar
15:55:24
3e27058c2452fee5bc6a170beca9e8bd6e60fea3aadce75f01525f40d38ad742  samplechart-0.1.0.tar
15:55:25
0c4bbba0616a338fc423ecd642cc77391b5ce001320ad022a00358f9ec424f70  samplechart-0.1.0.tar
```

## Workaround

To work around the issue, you can use the `helm-package-sha.sh` scrip included in this repo.
It produces the package produces sha256 of its content as last line of its output.
You will need to install gnu version of tar if you want to run it on macOS.

NOTE: the script does not allow parring options to `helm package` so you'd need to modify it if
require it.

To test it with the samplechart:
```sh
for i in {1..5}; do date +"%T" && ./helm-package-sha.sh | tail -1 && rm samplechart-0.1.0.tgz; sleep 1; done
```

You should get the following output:
```
bash-3.2$ for i in {1..5}; do date +"%T" && ./helm-package-sha.sh | tail -1 && rm samplechart-0.1.0.tgz; sleep 1; done
16:02:25
42de1047fda839cc2633f79b72715cd39e728955100d6392edaed78106a12399
16:02:26
42de1047fda839cc2633f79b72715cd39e728955100d6392edaed78106a12399
16:02:27
42de1047fda839cc2633f79b72715cd39e728955100d6392edaed78106a12399
16:02:28
42de1047fda839cc2633f79b72715cd39e728955100d6392edaed78106a12399
16:02:29
ae1b797a19d393f781aedaefdd2140919ad4274885171eabdefd39fad6ec714c
bash-3.2$
```
