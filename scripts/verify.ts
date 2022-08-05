import hre from "hardhat";
// import ora from "ora";
// import { ignoreAlreadyVerifiedError } from "./ignore-already-verified-error";

async function main(): Promise<void> {
  await verifyContract("0x2Ab023596B69E0Ec751171a26eD68E1C6e9dD044", []);
}
export const verifyContract = async (
  address: string,
  constructorArguments: Array<unknown>
): Promise<void> => {
  try {
    await hre.run("verify:verify", {
      address,
      constructorArguments,
    });
  } catch (err) {
    console.log(err);
  }
};

main()
  .then(() => {
    throw new Error("");
  })
  .catch((error: Error) => {
    console.error(error);
    throw new Error(error as unknown as string);
  });
