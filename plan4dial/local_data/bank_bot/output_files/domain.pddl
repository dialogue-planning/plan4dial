(define
    (domain bank-bot)
    (:requirements :strips)
    (:types )
    (:constants )
    (:predicates
        (select-account)
        (know__task)
        (tried-transfer)
        (tried-e-transfer)
        (tried-request-money)
        (tried-pay-bills)
        (tried-create)
        (know__account1)
        (know__account2)
        (know__funds)
        (know__contact)
        (know__bill)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (task-value-transfer_funds_between_accounts)
        (task-value-e-transfer)
        (task-value-request_money)
        (task-value-pay_bills)
        (task-value-create_account)
    )
    (:action offer-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
                (not (tried-transfer))
            )
        :effect
            (labeled-oneof offer-transfer__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-create_account))
                        (not (task-value-e-transfer))
                        (know__task)
                        (not (task-value-pay_bills))
                        (task-value-transfer_funds_between_accounts)
                        (not (task-value-request_money))
                    )
                )
                (outcome dont-want
                    (and
                        (tried-transfer)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-transfer-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-transfer_funds_between_accounts)
            )
        :effect
            (labeled-oneof get-transfer-options__get-options
                (outcome get-valid-options
                    (and
                        (know__account1)
                        (know__funds)
                        (know__account2)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__account1)
                (know__funds)
                (task-value-transfer_funds_between_accounts)
                (know__account2)
            )
        :effect
            (labeled-oneof confirm-transfer__transfer
                (outcome complete
                    (and
                        (tried-transfer)
                        (not (task-value-create_account))
                        (not (know__task))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (know__account2))
                        (not (know__funds))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action offer-e-transfer
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
                (not (tried-e-transfer))
            )
        :effect
            (labeled-oneof offer-e-transfer__start-task
                (outcome want-transfer
                    (and
                        (task-value-e-transfer)
                        (not (task-value-create_account))
                        (know__task)
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-e-transfer)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-e-transfer-options
        :parameters()
        :precondition
            (and
                (task-value-e-transfer)
                (not (force-statement))
            )
        :effect
            (labeled-oneof get-e-transfer-options__get-options
                (outcome get-valid-e-transfer
                    (and
                        (know__contact)
                        (select-account)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-e-transfer
        :parameters()
        :precondition
            (and
                (task-value-e-transfer)
                (not (force-statement))
                (know__account1)
                (know__contact)
                (know__funds)
            )
        :effect
            (labeled-oneof confirm-e-transfer__reset
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (tried-e-transfer)
                        (not (know__task))
                        (not (know__account1))
                        (not (know__contact))
                        (not (task-value-e-transfer))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (know__funds))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action offer-request
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
                (not (tried-request-money))
            )
        :effect
            (labeled-oneof offer-request__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-create_account))
                        (not (task-value-e-transfer))
                        (know__task)
                        (not (task-value-pay_bills))
                        (task-value-request_money)
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
                (outcome dont-want
                    (and
                        (tried-request-money)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-request-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-request_money)
            )
        :effect
            (labeled-oneof get-request-options__get-options
                (outcome get-valid-request
                    (and
                        (know__contact)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__contact)
                (task-value-request_money)
                (know__funds)
            )
        :effect
            (labeled-oneof confirm-request__reset
                (outcome complete
                    (and
                        (tried-request-money)
                        (not (task-value-create_account))
                        (not (know__task))
                        (not (know__contact))
                        (not (task-value-e-transfer))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (know__funds))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action offer-pay
        :parameters()
        :precondition
            (and
                (not (tried-pay-bills))
                (not (know__task))
                (not (force-statement))
            )
        :effect
            (labeled-oneof offer-pay__start-task
                (outcome want-pay
                    (and
                        (not (task-value-create_account))
                        (not (task-value-e-transfer))
                        (know__task)
                        (not (task-value-request_money))
                        (task-value-pay_bills)
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
                (outcome dont-want
                    (and
                        (tried-pay-bills)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-bill-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__account1)
                (task-value-pay_bills)
                (know__bill)
            )
        :effect
            (labeled-oneof confirm-bill-payment__reset
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (tried-pay-bills)
                        (not (know__task))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-pay_bills))
                        (not (know__bill))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action offer-new
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
                (not (tried-create))
            )
        :effect
            (labeled-oneof offer-new__start-task
                (outcome want-create
                    (and
                        (not (task-value-e-transfer))
                        (know__task)
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (task-value-create_account)
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
                (outcome dont-want
                    (and
                        (tried-create)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-create
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__account1)
                (task-value-create_account)
                (know__account2)
            )
        :effect
            (labeled-oneof confirm-create__reset
                (outcome complete
                    (and
                        (tried-create)
                        (not (task-value-create_account))
                        (not (know__task))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (know__account2))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (tried-transfer)
                (tried-request-money)
                (tried-create)
                (not (force-statement))
                (tried-e-transfer)
                (tried-pay-bills)
            )
        :effect
            (labeled-oneof complete__finish
                (outcome done
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof dialogue_statement__reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__select-account
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__account1))
                (select-account)
            )
        :effect
            (labeled-oneof slot-fill__select-account__validate-slot-fill
                (outcome account1_found
                    (and
                        (know__account1)
                        (not (select-account))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action slot-fill__get-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-pay_bills)
                (not (know__bill))
            )
        :effect
            (labeled-oneof slot-fill__get-payment__validate-slot-fill
                (outcome bill_found
                    (and
                        (know__bill)
                        (select-account)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action slot-fill__get-create
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-create_account)
                (not (know__account2))
            )
        :effect
            (labeled-oneof slot-fill__get-create__validate-slot-fill
                (outcome account2_found
                    (and
                        (have-message)
                        (know__account2)
                        (select-account)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
)
