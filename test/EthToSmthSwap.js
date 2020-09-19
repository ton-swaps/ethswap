const EthToSmthSwaps   = artifacts.require('EthToSmthSwaps')

const secret        = '0xc0809ce9f484fdcdfb2d5aabd609768ce0374ee97a1a5618ce4cd3f16c00a078'
const secretHash    = '0x55f1e894d911b3e18e48f8975cc3f93336e4b450bd5ed87594fce9bf72a59969'
const getSwapValue  = () => 0.1e18

const timeTravel = require('./time-travel')

contract('EthToSmthSwap >', async (accounts) => {

  const Owner = accounts[0]
  const btcOwner = accounts[1]
  const ethOwner = accounts[2]


  let Swap
  let swapValue

  before('setup contract', async () => {
    Swap   = await EthToSmthSwaps.deployed()
  })

  describe('Init >', () => {

    it('check creator balance', async () => {
      const ethOwnerBalance = await web3.eth.getBalance(ethOwner)

      assert.isTrue(ethOwnerBalance >= getSwapValue(), 'not enough balance')
    })
  })

  /**
   * Scenrio #1: 'Withdraw' case
   */
  describe('Scenario #1: Withdraw case >', () => {

    describe('Create Swap >', () => {

      before('Swap init', () => {
        swapValue = getSwapValue()
      })

      it('create swap', async () => {
        await Swap.createSwap(secretHash, btcOwner, {
          from: ethOwner,
          value: swapValue,
        })
      })

      it('check balance', async () => {
        const balance = await Swap.getBalance(ethOwner, {
          from: btcOwner,
        })

        assert.equal(swapValue, balance, 'Wrong balance')
      })
    })

    describe('Withdraw Swap >', () => {

      let btcOwnerBalance
      let withdrawTransactionCost

      before('before', async () => {
        btcOwnerBalance = await web3.eth.getBalance(btcOwner)
      })

      it('withdraw', async () => {
        const { receipt: { transactionHash, gasUsed } } = await Swap.withdraw(secret, ethOwner, {
          from: btcOwner,
        })
        const { gasPrice } = await web3.eth.getTransaction(transactionHash)

        withdrawTransactionCost = gasPrice * gasUsed
      })

      it('check participant balance', async () => {
        const _btcOwnerBalance = await web3.eth.getBalance(btcOwner)

        const expectedBalance = BigInt(btcOwnerBalance) - BigInt(withdrawTransactionCost) + BigInt(swapValue);
        assert.equal(expectedBalance.toString(), BigInt(_btcOwnerBalance).toString())
      })

      it('check secret', async () => {
        const _secret = await Swap.getSecret.call(btcOwner, {
          from: ethOwner,
        })

        assert.equal(secret, _secret)
      })

      // it('check swap cleaned', async () => {
      //   const result = await Swap.getInfo(ethOwner, btcOwner)
      //
      //   assert.equal(result[1], '0x0000000000000000000000000000000000000000', 'Invalid TokenAddress')
      // })

    })

  })

  /**
   * Scenrio #2: 'Refund' case
   */
  describe('Scenario #2: Refund case >', () => {

    describe('Create Swap >', () => {

      before('Swap init', () => {
        swapValue = getSwapValue()
      })

      it('create swap', async () => {
        await Swap.createSwap(secretHash, btcOwner, {
          from: ethOwner,
          value: swapValue,
        })
      })

      it('check balance', async () => {
        const balance = await Swap.getBalance(ethOwner, {
          from: btcOwner,
        })

        assert.equal(swapValue, balance, 'Wrong balance')
      })

      // it('check swap', async () => {
      //   const result = await Swap.getInfo(ethOwner, btcOwner)
      //
      //   assert.equal(result[1], secretHash, 'Invalid secretHash')
      //   assert.equal(result[3].toNumber(), swapValue, 'Invalid Balance')
      // })
    })

    describe('TimeOut >', () => {

      // it('time', (done) => {
      //   setTimeout(done, 6000)
      // })
    })

    describe('Refund Swap >', () => {

      let ethOwnerBalance
      let refundTransactionCost

      before('before', async () => {
        ethOwnerBalance = await web3.eth.getBalance(ethOwner)
      })

      it('refund', async () => {
        await timeTravel(3600 * 3)

        const { receipt: { transactionHash, gasUsed } } = await Swap.refund(btcOwner, {
          from: ethOwner,
        })

        const { gasPrice } = await web3.eth.getTransaction(transactionHash)

        refundTransactionCost = gasPrice * gasUsed
      })

      it('check creator balance', async () => {
        const _ethOwnerBalance = await web3.eth.getBalance(ethOwner)

        assert.equal((BigInt(ethOwnerBalance) - BigInt(refundTransactionCost) + BigInt(swapValue)).toString(), BigInt(_ethOwnerBalance).toString())
      })

      // it('check swap cleaned', async () => {
      //   const result = await Swap.getInfo.call(ethOwner, btcOwner)
      //
      //   assert.equal(result[1], '0x0000000000000000000000000000000000000000', 'Invalid TokenAddress')
      // })
    })

  })

  /**
   * Scenrio #2: 'Abort' case
   */
  describe('Scenario #3 Abort case >', () => {

    describe('Init Swap >', () => {

    })

    describe('TimeOut >', () => {

      // it('time', (done) => {
      //   setTimeout(done, 6000)
      // })
    })


  })

  // TODO add test case to check abort() then ethOwner created swap

})
