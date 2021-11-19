include "../node_modules/circomlib/circuits/mimcsponge.circom"

/*
  Inputs:
  - hash1 (pub)
  - hash2 (pub)
  - hash3 (pub)
  - msg (pub)
  - secret

  Intermediate values:
  - x (supposed to be hash of secret)
  
  Output:
  - msgAttestation
  
  Prove:
  - mimc(secret) == x
  - (x - hash1)(x - hash2)(x - hash3) == 0
  - msgAttestation == mimc(msg, secret)
*/

template Main() {
  signal private input secret;
  signal input hash1;
  signal input hash2;
  signal input hash3;
  signal input msg;

  signal x;

  signal output msgAttestation;

  component mimcSecret = MiMCSponge(1, 220, 1);
  mimcSecret.ins[0] <== secret;
  mimcSecret.k <== 0;
  x <== mimcSecret.outs[0];

  signal temp;
  temp <== (x - hash1) * (x - hash2);
  0 === temp * (x - hash3);
  
  component mimcAttestation = MiMCSponge(2, 220, 1);
  mimcAttestation.ins[0] <== msg;
  mimcAttestation.ins[1] <== secret;
  mimcAttestation.k <== 0;
  msgAttestation <== mimcAttestation.outs[0];
}

component main = Main();