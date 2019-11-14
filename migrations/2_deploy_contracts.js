const CMC = artifacts.require("CMC");

module.exports = function (deployer) {
    const init = 10000;  // initial value
    deployer.deploy(CMC, init, { gas: 7000000 });
};
