import { expect } from './shared/expect'
import { resetFork } from './shared/mainnetForkHelpers'
import { ALICE_ADDRESS } from './shared/constants'
import hre from 'hardhat'
import deployUniversalRouter from './shared/deployUniversalRouter'
import { UniversalRouter } from '../../typechain'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

const { ethers } = hre

describe('UniversalRouter receive', () => {
  let alice: SignerWithAddress
  let router: UniversalRouter

  beforeEach(async () => {
    await resetFork()
    alice = await ethers.getSigner(ALICE_ADDRESS)
    await hre.network.provider.request({
      method: 'hardhat_impersonateAccount',
      params: [ALICE_ADDRESS],
    })
    router = (await deployUniversalRouter(alice.address)).connect(alice) as UniversalRouter
  })

  it('reverts when ETH is sent directly from an EOA', async () => {
    await expect(
      alice.sendTransaction({ to: router.address, value: 1 })
    ).to.be.revertedWithCustomError(router, 'InvalidEthSender')
  })
})
