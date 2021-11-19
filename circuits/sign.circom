include "../node_modules/circomlib/circuits/mimcsponge.circom"
include "../node_modules/circomlib/circuits/comparators.circom";

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

//////
// Inputs:
//  - hash (pub)
//  - msgAttestation (pub)
//  - msg (pub)
//  - secret
 
// Outputs:
//  - msgAttestation
 
// Prove:
//  - msgAttestation == mimc(msg, secret)
//  - hash = mimc(secret)


template RevealSigner() {
    signal input hash;
    signal input msg;
    signal input msgAttestation;
    signal private input secret;

    // hash = mimc(secret)
    component mimcHash = MiMCSponge(1, 220, 1);
    mimcHash.ins[0] <== secret;
    mimcHash.k <== 0;
    hash === mimcHash.outs[0];

    // msgAttestation !== mimc(msg, secret)
    component mimcAttestation = MiMCSponge(2, 220, 1);
    mimcAttestation.ins[0] <== msg;
    mimcAttestation.ins[1] <== secret;
    mimcAttestation.k <== 0;

    msgAttestation === mimcAttestation.outs[0];
}


// denySignature

// Inputs:
//  - hash (pub)
//  - msg (pub)
//  - secret

// Outputs:
//  - msgAttestation 

// Prove
//  - msgAttestation != mimc(msg, secret)
//  - hash = mimc(secret)

template DenySignature() {
    signal input hash;
    signal input msgAttestation;
    signal input msg;
    signal private input secret;

    // hash = mimc(secret)
    component mimcHash = MiMCSponge(1, 220, 1);
    mimcHash.ins[0] <== secret;
    mimcHash.k <== 0;
    hash === mimcHash.outs[0];

     // msgAttestation == mimc(msg, secret)
    component mimcAttestation = MiMCSponge(2, 220, 1);
    mimcAttestation.ins[0] <== msg;
    mimcAttestation.ins[1] <== secret;
    mimcAttestation.k <== 0;
  
    component areMessagesEql = IsEqual();
    areMessagesEql.in[0] <== msgAttestation;
    areMessagesEql.in[1] <== mimcAttestation.outs[0];

    areMessagesEql.out === 0;
}

component main = DenySignature();