<script setup>
  import { ref } from 'vue'
  import axios from 'axios'

  const petStoreFormForm = ref(null)
  const isFormValid = ref(false)
  const isStoreButtonDisabled = ref(false)

  const petName = ref('')
  const petCategory = ref()
  const petStatus = ref()
  const petTags = ref([])
  const petImage = ref()

  const categories = ref([
    { id: 1, name: 'Dogs' },
    { id: 2, name: 'Cats' },
    { id: 3, name: 'Birds' },
  ])

  const statuses = ref([
    'available',
    'pending',
    'sold',
  ])

  const tags = ref([
    { id: 1, name: 'cuteanimals' },
    { id: 2, name: 'partyanimals' },
    { id: 3, name: 'babyanimals' },
    { id: 4, name: 'exoticanimals' }
  ])

  const isStoreError = ref(false)

  const rules = {
    userName: [
      v => !!v || 'Name is required',
      v => (v && v.length > 2) || 'Please enter more than 2 characters'
    ],
    userCategory: [
      v => !!v || 'Category is required'
    ],
    userStatus: [
      v => !!v || 'Status is required'
    ],
    petImage: [
      v => !!v[0] || 'Image is required',
      v => v[0]?.size < 5000000 || 'The maximum file size is 5MB'
    ]
  }

  /**
   * Single file size validation: no more than 5 mb
   * @param file
   * @returns {boolean}
   */
  const validateFileSize = (file) => {
    const fileSizeMB = file[0].size / (1024 * 1024)
    console.log('fileSizeMB', fileSizeMB)
    return fileSizeMB <= 5
  }

  /**
   * File size validation rule
   * @param file
   * @returns {boolean|string}
   */
  const fileSizesRule = (file) => {
    console.log('file', file)
    if (!validateFileSize(file)) {
      return `The maximum file size is 5MB`
    }

    return true
  }

  const storeData = () => {

    isStoreError.value = false

    // run validation
    petStoreFormForm.value.validate()

    if (isFormValid.value) {

      isStoreButtonDisabled.value = true

      // Prepare post data
      const formData = new FormData()

      formData.append('name', petName.value)
      formData.append('category_id', petCategory.value)
      formData.append('status', petStatus.value)
      formData.append('image', petImage.value)

      const tags = petTags.value;

      for (let i = 0; i < tags.length; i++) {
        formData.append('tags[]', tags[i]);
      }

      // get API url from .env
      const url = import.meta.env.VITE_API_URL

      axios.post(url + '/api/pet', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json'
        }

      }).then(() => {

        // set default values
        petName.value = ''
        petCategory.value = null
        petStatus.value = null
        petTags.value = []
        petImage.value = null

        petStoreFormForm.value.resetValidation()

        // fetch new data from back to list in FileList component
        document.dispatchEvent(new CustomEvent('fetchData'))

      }).catch(error => {

        isStoreError.value = true
        console.error('error', error);
      }).finally(() => {

        isStoreButtonDisabled.value = false
      })
    }
  }
</script>

<template>
  <div class="mb-10">
    <h3 class="text-center mb-3">Add a new Pet</h3>
    <v-alert
      v-if="isStoreError"
      color="error"
      class="ma-3"
      closable
    >
      Something went wrong, please try again later
    </v-alert>
    <v-form
      ref="petStoreFormForm"
      v-model="isFormValid"
    >
      <v-text-field
        ref="nameInput"
        v-model.trim="petName"
        :rules="rules.userName"
        variant="outlined"
        rounded
        label="Name"
        class="mb-2"
      ></v-text-field>
      <v-select
        v-model="petCategory"
        :items="categories"
        :rules="rules.userCategory"
        item-title="name"
        item-value="id"
        label="Categories"
        variant="outlined"
        rounded
      ></v-select>
      <v-select
        v-model="petStatus"
        :items="statuses"
        :rules="rules.userStatus"
        label="Status"
        variant="outlined"
        rounded
      ></v-select>
      <v-select
        v-model="petTags"
        :items="tags"
        item-title="name"
        item-value="id"
        label="Tags"
        chips
        multiple
        variant="outlined"
        rounded
      ></v-select>
      <v-file-input
        ref="imageInput"
        v-model="petImage"
        :rules="rules.petImage"
        accept="image/jpeg, image/jpg, image/png, image/webp, image/tiff, image/bmp"
        label="Image"
        variant="outlined"
        prepend-icon="mdi-camera"
        rounded
        chips
        show-size
        class="mb-2"
      ></v-file-input>
      <v-alert
        title="We only upload images like this:"
        type="info"
        variant="tonal"
        class="mb-3"
      >
        <template #text>
          <ul>
            <li>Allowed file types JPG, PNG, WebP, TIFF, BMP</li>
            <li>Maximum file size 5 MB</li>
          </ul>
        </template>
      </v-alert>
    </v-form>
    <v-btn
      block
      rounded="xl"
      color="green"
      size="x-large"
      :disabled="isStoreButtonDisabled"
      @click="storeData"
    >
      Store
    </v-btn>
  </div>
</template>

<style scoped>
.v-alert {
  border-radius: 24px;
}
</style>
