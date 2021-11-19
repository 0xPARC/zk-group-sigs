include "../node_modules/circomlib/circuits/mimcsponge.circom"
include "../node_modules/circomlib/circuits/comparators.circom";

/*
  Inputs:
   - hash (pub)
   - msg (pub)
   - msgAttestation (pub)
   - secret (private)

  Prove
   - hash = mimc(secret)
   - msgAttestation != mimc(msg, secret)
*/

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
