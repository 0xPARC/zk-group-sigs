include "../node_modules/circomlib/circuits/mimcsponge.circom"

/*
  Inputs:
   - hash (pub)
   - msgAttestation (pub)
   - msg (pub)
   - secret
 
  Prove:
   - msgAttestation == mimc(msg, secret)
   - hash = mimc(secret)
*/

template RevealSigner() {
    signal private input secret;
    signal input hash;
    signal input msg;
    signal input msgAttestation;

    // hash = mimc(secret)
    component mimcHash = MiMCSponge(1, 220, 1);
    mimcHash.ins[0] <== secret;
    mimcHash.k <== 0;
    hash === mimcHash.outs[0];

    // msgAttestation === mimc(msg, secret)
    component mimcAttestation = MiMCSponge(2, 220, 1);
    mimcAttestation.ins[0] <== msg;
    mimcAttestation.ins[1] <== secret;
    mimcAttestation.k <== 0;

    msgAttestation === mimcAttestation.outs[0];
}

component main = RevealSigner();