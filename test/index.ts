import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import { CryptonianWar } from "../typechain/index";

let warContract: CryptonianWar,
  deployer: SignerWithAddress,
  userOne: SignerWithAddress,
  userTwo: SignerWithAddress,
  userThree: SignerWithAddress,
  userFour: SignerWithAddress,
  userFive: SignerWithAddress;

before(async () => {
  [deployer, userOne, userTwo, userThree, userFour, userFive] =
    await ethers.getSigners();
  const CryptonianWar = await ethers.getContractFactory("CryptonianWar");
  warContract = (await CryptonianWar.deploy()) as CryptonianWar;
  await warContract.deployed();
});
describe("Cryptonian War", function () {
  it("has URI", async function () {
    expect(await warContract.uri(0)).to.be.string("");
  });
});
describe("Check Roles has being assigned", function () {
  it("should have set url role", async () => {
    expect(
      await warContract.hasRole(
        await warContract.URI_SETTER_ROLE(),
        deployer.address
      )
    ).to.equal(true);
  });
  it("should have LISTER role", async () => {
    expect(
      await warContract.hasRole(
        await warContract.LISTER_ROLE(),
        deployer.address
      )
    ).to.equal(true);
  });
  it("should have PAUSER role", async () => {
    expect(
      await warContract.hasRole(
        await warContract.PAUSER_ROLE(),
        deployer.address
      )
    ).to.equal(true);
  });
  it("should have PAUSER role", async () => {
    expect(
      await warContract.hasRole(
        await warContract.MINTER_ROLE(),
        deployer.address
      )
    ).to.equal(true);
  });
  it("expect deployer to have all roles", async () => {});
});
describe("NFT Minting", async () => {
  it("should mint many nfts to many addresses", async () => {
    const mint = warContract.mintManyToMany(
      [
        userOne.address,
        userTwo.address,
        userThree.address,
        userFour.address,
        userFive.address,
      ],
      [2, 2, 1, 1, 2],
      [1, 2, 3, 4, 5]
    );
    expect(await mint).emit("ERC1155Upgradeable", "TransferSingle");
  });
  it("should update the balance of the userOne", async () => {
    await expect(await warContract.balanceOf(userOne.address, 1)).eq(2);
  });
  it("should update the balance of the userTow", async () => {
    await expect(await warContract.balanceOf(userTwo.address, 2)).eq(2);
  });
  it("should update the balance of the userThree", async () => {
    await expect(await warContract.balanceOf(userThree.address, 3)).eq(1);
  });
  it("should update the balance of the userFour", async () => {
    await expect(await warContract.balanceOf(userFour.address, 4)).eq(1);
  });
});
