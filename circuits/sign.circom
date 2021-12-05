include "../node_modules/circomlib/circuits/mimcsponge.circom"
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/gates.circom"

template Main(GROUP_SIZE) {
  signal private input secret;
  signal input hashes[GROUP_SIZE];
  signal input msg;

  signal userPub;

  signal output msgAttestation;

  // MiMC hash of secret
  component mimcSecret = MiMCSponge(1, 220, 1);
  mimcSecret.ins[0] <== secret;
  mimcSecret.k <== 0;
  userPub <== mimcSecret.outs[0];

  component eqs[GROUP_SIZE];
  component is_hash_present[GROUP_SIZE];

  for(var i=0; i<GROUP_SIZE; i++){
    eqs[i] = IsEqual();
    eqs[i].in[0] <== userPub;
    eqs[i].in[1] <== hashes[i];

    is_hash_present[i] = OR();
  }

  // a big loop of ORs
  for(var i=1; i<GROUP_SIZE; i++){
    is_hash_present[i].a <== eqs[i].out;
    is_hash_present[i].b <== i == 1 ? eqs[0].out : is_hash_present[i-1].out;
  }

  // assert that hash is present
  is_hash_present[GROUP_SIZE-1].out === 1;
  
  // sign and return output message using user's secret
  component mimcAttestation = MiMCSponge(2, 220, 1);
  mimcAttestation.ins[0] <== msg;
  mimcAttestation.ins[1] <== secret;
  mimcAttestation.k <== 0;
  msgAttestation <== mimcAttestation.outs[0];
}

component main = Main(40);