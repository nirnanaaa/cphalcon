
/*
 +------------------------------------------------------------------------+
 | Phalcon Framework                                                      |
 +------------------------------------------------------------------------+
 | Copyright (c) 2011-2014 Phalcon Team (http://www.phalconphp.com)       |
 +------------------------------------------------------------------------+
 | This source file is subject to the New BSD License that is bundled     |
 | with this package in the file docs/LICENSE.txt.                        |
 |                                                                        |
 | If you did not receive a copy of the license and are unable to         |
 | obtain it through the world-wide-web, please send an email             |
 | to license@phalconphp.com so we can send you a copy immediately.       |
 +------------------------------------------------------------------------+
 | Authors: Andres Gutierrez <andres@phalconphp.com>                      |
 |          Eduar Carvajal <eduar@phalconphp.com>                         |
 +------------------------------------------------------------------------+
 */

namespace Phalcon;

/**
 * Phalcon\Validation
 *
 * Allows to validate data using validators
 */
class Validation extends Phalcon\Di\Injectable
{
	protected _data;

	protected _entity;

	protected _validators;

	protected _filters;

	protected _messages;

	protected _defaultMessages;

        protected _labels;

	protected _values;

	/**
	 * Phalcon\Validation constructor
	 *
	 * @param array validators
	 */
	public function __construct(validators=null)
	{

		if typeof validators != "null" {
			if typeof validators != "array" {
				throw new Phalcon\Validation\Exception("Validators must be an array");
			}
			let this->_validators = validators;
		}

                this->setDefaultMessages();

		/**
		 * Check for an 'initialize' method
		 */
		if (method_exists(this, "initialize")) {
			this->{"initialize"}();
		}
	}

	/**
	 * Validate a set of data according to a set of rules
	 *
	 * @param array|object data
	 * @param object entity
	 * @return Phalcon\Validation\Message\Group
	 */
	public function validate(data=null, entity=null) -> <Phalcon\Validation\Message\Group>
	{
		var validators, messages, scope, field, validator, notCachedCall;

		let validators = this->_validators;
		if typeof validators != "array" {
			throw new Phalcon\Validation\Exception("There are no validators to validate");
		}

		/**
		 * Clear pre-calculated values
		 */
		let this->_values = null;

		/**
		 * Implicitly creates a Phalcon\Validation\Message\Group object
		 */
		let messages = new Phalcon\Validation\Message\Group();

		/**
		 * Validation classes can implement the 'beforeValidation' callback
		 */
		if method_exists(this, "beforeValidation") {
			if this->{"beforeValidation"}(data, entity, messages) === false {
				return messages;
			}
		}

		let this->_messages = messages;

		if typeof data == "array" {
			let this->_data = data;
		} else {
			if typeof data == "object" {
				let this->_data = data;
			}
		}

		for scope in validators {

			if typeof scope != "array" {
				throw new Phalcon\Validation\Exception("The validator scope is not valid");
			}

			let field = scope[0],
				validator = scope[1];

			if typeof validator != "object" {
				throw new Phalcon\Validation\Exception("One of the validators is not valid");
			}

			/**
			 * Check if the validation must be canceled if this validator fails
			 */
                        let notCachedCall = "validate";
			if validator->{notCachedCall}(this, field) === false {
                                let notCachedCall = "getOption";
				if (validator->{notCachedCall}("cancelOnFail")) {
					break;
				}
			}
		}

		/**
		 * Get the messages generated by the validators
		 */
		let messages = this->_messages;
		if method_exists(this, "afterValidation") {
			this->{"afterValidation"}(data, entity, messages);
		}

		return messages;
	}

	/**
	 * Adds a validator to a field
	 *
	 * @param string field
	 * @param Phalcon\Validation\ValidatorInterface validator
	 * @return Phalcon\Validation
	 */
	public function add(string field, <Phalcon\Validation\ValidatorInterface> validator) -> <Phalcon\Validation>
	{

		if typeof validator != "object" {
			throw new Phalcon\Validation\Exception("The validator must be an object");
		}

		let this->_validators[] = [field, validator];
		return this;
	}

	/**
	 * Adds filters to the field
	 *
	 * @param string field
	 * @param array|string field
	 * @return Phalcon\Validation
	 */
	public function setFilters(string field, filters) -> <Phalcon\Validation>
	{
		let this->_filters[field] = filters;
		return this;
	}

	/**
	 * Returns all the filters or a specific one
	 *
	 * @param string field
	 * @return mixed
	 */
	public function getFilters(var field=null)
	{
		var filters, fieldFilters;
		let filters = this->_filters;
		if typeof field == "string" {
			if fetch fieldFilters, filters[field] {
				return fieldFilters;
			}
			return null;
		}
		return filters;
	}

	/**
	 * Returns the validators added to the validation
	 *
	 * @return array
	 */
	public function getValidators()
	{
		return this->_validators;
	}

	/**
	 * Returns the bound entity
	 *
	 * @return object
	 */
	public function getEntity()
	{
		return this->_entity;
	}

        /**
	 * Adds default messages to validators
	 *
	 * @param array messages
         * @return array
	 */
	public function setDefaultMessages(messages=null)
	{
                var defaultMessages;

                if typeof messages == "null" {
			let messages = [];
		}
                if typeof messages != "array" {
                        throw new Phalcon\Validation\Exception("Messages must be an array");
                }
                let defaultMessages = [
                        "Alnum": "Field :field must contain only alphanumeric characters",
                        "Alpha": "Field :field must contain only letters",
                        "Between": ":field is not between a valid range",
                        "Confirmation": "Value of :field and :with don't match",
                        "Digit": "Field :field must be numeric",
                        "Email": "Value of field :field must have a valid e-mail format",
                        "ExclusionIn": "Value of field :field must not be part of list: :domain",
                        "FileValid": "File :field is not valid",
                        "FileEmpty": "File :field must not be empty",
                        "FileIniSize": "The uploaded file exceeds the max filesize",
                        "FileSize": "Max filesize of file :field is :max",
                        "FileType": "Type of :field is not valid",
                        "FileMinResolution": "Min resolution of :field is :min",
                        "FileMaxResolution": "Max resolution of :field is :max",
                        "Identical": ":field does not have the expected value",
                        "InclusionIn": "Value of field :field must be part of list: :domain",
                        "PresenceOf": ":field is required",
                        "Regex": "Value of field :field doesn't match regular expression",
                        "TooLong": "Value of field :field exceeds the maximum :max characters",
                        "TooShort": "Value of field :field is less than the minimum :min characters",
                        "Uniqueness": ":field is already present in another record",
                        "Url": ":field does not have a valid url format"
                ];

		let this->_defaultMessages = array_merge(defaultMessages, messages);
                return this->_defaultMessages;
	}

        /**
	 * Get default message for validator type
	 *
	 * @param string type
	 * @return string
	 */
	public function getDefaultMessage(string! type)
	{
		return this->_defaultMessages[type];
	}

	/**
	 * Returns the registered validators
	 *
	 * @return Phalcon\Validation\Message\Group
	 */
	public function getMessages() -> <Phalcon\Validation\Message\Group>
	{
		return this->_messages;
	}

        /**
	 * Adds labels for fields
	 *
	 * @param array labels
	 */
	public function setLabels(labels)
	{
                if typeof labels != "array" {
                        throw new Phalcon\Validation\Exception("Labels must be an array");
                }
                let this->_labels = labels;
        }

        /**
	 * Get label for field
	 *
	 * @param string field
	 * @return mixed
	 */
	public function getLabel(string! field)
	{
		var labels, value;
		let labels = this->_labels;
		if typeof labels == "array" {
			if fetch value, labels[field] {
				return value;
			}
		}
		return null;
	}

	/**
	 * Appends a message to the messages list
	 *
	 * @param Phalcon\Validation\MessageInterface message
	 * @return Phalcon\Validation
	 */
	public function appendMessage(<Phalcon\Validation\MessageInterface> message) -> <Phalcon\Validation>
	{
		var messages;
		let messages = this->_messages;
		messages->appendMessage(message);
		return this;
	}

	/**
	 * Assigns the data to an entity
	 * The entity is used to obtain the validation values
	 *
	 * @param string entity
	 * @param string data
	 * @return Phalcon\Validation
	 */
	public function bind(entity, data) -> <Phalcon\Validation>
	{
		if typeof entity != "object" {
			throw new Phalcon\Validation\Exception("The entity must be an object");
		}

		if typeof data != "array" {
			if typeof data != "object" {
				throw new Phalcon\Validation\Exception("The data to validate must be an array or object");
			}
		}

		let this->_entity = entity,
			this->_data = data;

		return this;
	}

	/**
	 * Gets the a value to validate in the array/object data source
	 *
	 * @param string field
	 * @return mixed
	 */
	public function getValue(string field)
	{
		var entity, method, value, data, values,
			filters, fieldFilters, dependencyInjector,
			filterService;

		let entity = this->_entity;

		/**
		 * If the entity is an object use it to retrieve the values
		 */
		if typeof entity == "object" {
			let method = "get" . field;
			if method_exists(entity, method) {
				let value = entity->{method}();
			} else {
				if method_exists(entity, "readAttribute") {
					let value = entity->readAttribute(field);
				} else {
					if isset entity->{field} {
						let value = entity->{field};
					} else {
						let value = null;
					}
				}
			}
			return value;
		}

		let data = this->_data;

		if typeof data != "array" {
			if typeof data != "object" {
				throw new Phalcon\Validation\Exception("There is no data to validate");
			}
		}

		/**
		 * Check if there is a calculated value
		 */
		let values = this->_values;
		if fetch value, values[field] {
			return value;
		}

		let value = null;
		if typeof data == "array" {
			if isset data[field] {
				let value = data[field];
			}
		} else  {
			if typeof data == "object" {
				if isset data->{field} {
					let value = data->{field};
				}
			}
		}

		if typeof value != "null" {

			let filters = this->_filters;
			if typeof filters == "array" {

				if fetch fieldFilters, filters[field] {

					if fieldFilters {

						let dependencyInjector = this->getDI();
						if typeof dependencyInjector != "object" {
							let dependencyInjector = Phalcon\Di::getDefault();
							if typeof dependencyInjector != "object" {
								throw new Phalcon\Validation\Exception("A dependency injector is required to obtain the 'filter' service");
							}
						}

						let filterService = dependencyInjector->getShared("filter");
						if typeof filterService != "object" {
							throw new Phalcon\Validation\Exception("Returned 'filter' service is invalid");
						}

						return filterService->sanitize(value, fieldFilters);
					}
				}
			}

			/**
			 * Cache the calculated value
			 */
			let this->_values[field] = value;

			return value;
		}

		return null;
	}

}
