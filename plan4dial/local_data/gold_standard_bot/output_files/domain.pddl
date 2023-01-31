(define
    (domain day-planner)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__location)
        (know__phone-number)
        (maybe-know__phone-number)
        (know__cuisine)
        (maybe-know__cuisine)
        (know__have_allergy)
        (have_allergy)
        (know__food_restriction)
        (know__budget)
        (know__outing_type)
        (maybe-know__outing_type)
        (know__conflict)
        (conflict)
        (know__restaurant)
        (know__outing)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (allow_single_slot_outing_type)
        (allow_single_slot_budget)
        (forcing__get-allergy)
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (know__have_allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-allergy
                (outcome indicate_allergy
                    (and
                        (know__have_allergy)
                        (have_allergy)
                        (forcing__get-allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (have_allergy))
                        (know__have_allergy)
                        (not (conflict))
                        (know__conflict)
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
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (know__have_allergy)
                (have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-allergy
                (outcome update_allergy
                    (and
                        (not (forcing__get-allergy))
                        (know__food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (not (forcing__get-allergy))
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action check-conflicts
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (know__have_allergy)
                (have_allergy)
                (know__location)
                (not (know__conflict))
                (know__food_restriction)
                (not (force-statement))
                (know__cuisine)
            )
        :effect
            (labeled-oneof         check-conflicts
                (outcome restriction-dessert
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome restriction-mexican
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome no-restriction-1
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-2
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-3
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-4
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (force-statement))
                (conflict)
                (know__conflict)
            )
        :effect
            (labeled-oneof         reset
                (outcome reset-values
                    (and
                        (not (maybe-know__cuisine))
                        (not (know__food_restriction))
                        (have-message)
                        (not (know__conflict))
                        (not (know__cuisine))
                        (not (know__have_allergy))
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (not (force-statement))
                (know__conflict)
                (not (conflict))
                (not (know__restaurant))
                (know__cuisine)
            )
        :effect
            (labeled-oneof         assign_restaurant
                (outcome set-mexican
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (know__restaurant)
                    )
                )
            )
    )
    (:action set-outing
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (know__outing_type)
                (not (maybe-know__outing_type))
                (not (force-statement))
                (know__budget)
            )
        :effect
            (labeled-oneof         assign_outing
                (outcome set-club
                    (and
                        (know__outing)
                    )
                )
                (outcome set-library
                    (and
                        (know__outing)
                    )
                )
                (outcome set-theater
                    (and
                        (know__outing)
                    )
                )
                (outcome set-golf
                    (and
                        (know__outing)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (know__phone-number)
                (not (maybe-know__phone-number))
                (know__location)
                (not (force-statement))
                (know__outing)
                (know__restaurant)
            )
        :effect
            (labeled-oneof         finish
                (outcome finish
                    (and
                        (goal)
                        (know__goal)
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
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__get-location
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (know__location))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome location_found
                    (and
                        (have-message)
                        (force-statement)
                        (know__location)
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
    (:action slot-fill__get-phone-number
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (maybe-know__phone-number))
                (not (force-statement))
                (not (know__phone-number))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome phone-number_found
                    (and
                        (know__phone-number)
                        (not (maybe-know__phone-number))
                    )
                )
                (outcome phone-number_maybe-found
                    (and
                        (maybe-know__phone-number)
                        (not (know__phone-number))
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
    (:action clarify__phone-number
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (maybe-know__phone-number)
                (not (force-statement))
                (not (know__phone-number))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (know__phone-number)
                        (not (maybe-know__phone-number))
                    )
                )
                (outcome deny
                    (and
                        (not (maybe-know__phone-number))
                        (not (know__phone-number))
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
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (maybe-know__cuisine))
                (not (know__cuisine))
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome cuisine_found
                    (and
                        (have-message)
                        (not (maybe-know__cuisine))
                        (force-statement)
                        (know__cuisine)
                    )
                )
                (outcome cuisine_maybe-found
                    (and
                        (not (know__cuisine))
                        (maybe-know__cuisine)
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
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (know__cuisine))
                (maybe-know__cuisine)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-know__cuisine))
                        (know__cuisine)
                    )
                )
                (outcome deny
                    (and
                        (not (maybe-know__cuisine))
                        (not (know__cuisine))
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
    (:action slot-fill__get_outing
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (know__outing_type))
                (not (maybe-know__outing_type))
                (not (force-statement))
                (not (know__budget))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome budget_found-outing_type_found
                    (and
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                        (know__budget)
                    )
                )
                (outcome budget_found-outing_type_maybe-found
                    (and
                        (not (know__outing_type))
                        (maybe-know__outing_type)
                        (know__budget)
                    )
                )
                (outcome budget_found
                    (and
                        (allow_single_slot_outing_type)
                        (have-message)
                        (force-statement)
                        (know__budget)
                    )
                )
                (outcome outing_type_found
                    (and
                        (allow_single_slot_budget)
                        (have-message)
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                        (force-statement)
                    )
                )
                (outcome outing_type_maybe-found
                    (and
                        (not (know__outing_type))
                        (allow_single_slot_budget)
                        (maybe-know__outing_type)
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
    (:action single_slot__outing_type
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (allow_single_slot_outing_type)
                (not (know__outing_type))
                (not (maybe-know__outing_type))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome fill-slot
                    (and
                        (not (allow_single_slot_outing_type))
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome slot-unclear
                    (and
                        (not (know__outing_type))
                        (maybe-know__outing_type)
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
    (:action single_slot__budget
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (allow_single_slot_budget)
                (not (know__budget))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome fill-slot
                    (and
                        (not (allow_single_slot_budget))
                        (know__budget)
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
    (:action clarify__outing_type
        :parameters()
        :precondition
            (and
                (not (know__outing_type))
                (maybe-know__outing_type)
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome deny
                    (and
                        (not (know__outing_type))
                        (allow_single_slot_outing_type)
                        (not (maybe-know__outing_type))
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
