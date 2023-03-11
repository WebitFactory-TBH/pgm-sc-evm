//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

/**
 * @title Pagamentio
 * @dev WebitFactory
 */
contract Pagamentio is
    PausableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    // structs
    struct Receiver {
        address addr;
        uint256 amount;
    }

    struct Payment {
        address creator;
        Receiver[] receivers;
        uint256 totalAmount;
        string identifier;
        Status status;
    }

    enum Status {
        Pending,
        Completed,
        Cancelled
    }

    // data
    mapping(string => Payment) private payments;

    // guards
    modifier paymentExists(string memory index) {
        require(
            payments[index].creator != address(0),
            'Payment link does not exist'
        );
        _;
    }

    modifier paymentHasStatus(string memory index, Status status) {
        require(
            payments[index].status == status,
            'Payment link does not have the required status'
        );
        _;
    }

    modifier sentEnoughEth(string memory index) {
        require(
            payments[index].totalAmount == msg.value,
            'Not enough ETH sent to complete payment (check required/minimum amount)'
        );
        _;
    }

    modifier onlyPaymentCreator(string memory index) {
        require(
            payments[index].creator == msg.sender,
            'Only the payment link creator can call this function'
        );
        _;
    }

    // events
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event PaymentCreated(
        address indexed creator,
        Payment payment,
        string indexed identifier
    );
    event PaymentCancelled(string indexed identifier);
    event PaymentCompleted(string indexed identifier);

    // METHODS
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    function createPayment(
        Receiver[] memory receivers,
        string memory identifier
    ) public whenNotPaused nonReentrant {
        uint256 receiversLength = receivers.length;
        uint256 totalAmount = 0;
        Payment storage payment = payments[identifier];

        for (uint256 i = 0; i < receiversLength; ++i) {
            totalAmount += receivers[i].amount;
            payment.receivers.push(
                Receiver({addr: receivers[i].addr, amount: receivers[i].amount})
            );
        }

        payment.creator = msg.sender;
        payment.totalAmount = totalAmount;
        payment.identifier = identifier;
        payment.status = Status.Pending;

        emit PaymentCreated(msg.sender, payment, identifier);
    }

    function cancelPayment(string memory identifier)
        public
        whenNotPaused
        paymentExists(identifier)
        paymentHasStatus(identifier, Status.Pending)
        onlyPaymentCreator(identifier)
        nonReentrant
    {
        payments[identifier].status = Status.Cancelled;

        emit PaymentCancelled(identifier);
    }

    function completePayment(string memory identifier)
        public
        payable
        whenNotPaused
        paymentExists(identifier)
        paymentHasStatus(identifier, Status.Pending)
        sentEnoughEth(identifier)
        nonReentrant
    {
        uint256 receiversLength = payments[identifier].receivers.length;
        for (uint256 i = 0; i < receiversLength; ++i) {
            payable(payments[identifier].receivers[i].addr).transfer(
                payments[identifier].receivers[i].amount
            );
        }

        payments[identifier].status = Status.Completed;

        emit PaymentCompleted(identifier);
    }

    function pause() public onlyOwner nonReentrant {
        _pause();
    }

    function unpause() public onlyOwner nonReentrant {
        _unpause();
    }
}
